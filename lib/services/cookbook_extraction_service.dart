import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import 'firestore_service.dart';
import 'recipe_ai_service.dart';

class CookbookExtractionService {
  final FirestoreService _firestore = FirestoreService();
  final RecipeAiService _aiService = RecipeAiService();

  /// Extract recipes from PDF with optional progress callback
  Future<List<Recipe>> extractRecipes(
    File pdfFile, {
    Function(String)? onProgress,
  }) async {
    try {
      // 1. Calculate Hash for Caching
      onProgress?.call('Readin PDF file...');
      final bytes = await pdfFile.readAsBytes();
      final hash = sha256.convert(bytes).toString();
      debugPrint("🔐 PDF Hash: $hash");

      // 2. Check Cache
      final cacheDoc = await _firestore.db.collection('cookbook_cache').doc(hash).get();
      if (cacheDoc.exists && cacheDoc.data() != null) {
         final data = cacheDoc.data()!;
         if (data['recipes'] != null) {
            debugPrint("⚡ CACHE HIT: Returning stored recipes for $hash");
            onProgress?.call('Recipes found in cache! Loading...');
            
            final List<dynamic> jsonRecipes = data['recipes'];
            return jsonRecipes.map((map) => Recipe.fromMap(map, map['id'] ?? const Uuid().v4())).toList();
         }
      }
      
      debugPrint("🐌 CACHE MISS: Proceeding with AI extraction...");

      // 3. Extract Text from PDF (if not in cache)
      final text = await _extractPdfText(pdfFile).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('PDF reading timed out. File might be too large or corrupted.'),
      );
      
      if (text.isEmpty) {
        throw Exception('No text found in PDF. It might be an image scan. Try a PDF with selectable text.');
      }
      
      if (text.length < 50) {
        throw Exception('PDF text is too short. Make sure the PDF contains recipe content.');
      }
      
      debugPrint("📄 Extracted ${text.length} characters from PDF");

      // 4. Chunking Logic with Overlap
      // Overlap by 500 chars to ensure recipes split across chunks are captured in at least one.
      final chunks = _splitTextIntoChunks(text, 2000, overlap: 500); 
      
      List<Recipe> allRecipes = [];

      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        final chunkPreview = chunk.length > 100 ? chunk.substring(0, 100).replaceAll('\n', ' ') : chunk;
        
        onProgress?.call('Analyzing part ${i + 1} of ${chunks.length}...');
        debugPrint("🧩 Processing chunk ${i + 1}/${chunks.length} (${chunk.length} chars) - Start: '$chunkPreview...'");
        
        try {
          final recipes = await _aiService.analyzeText(chunk).timeout(
            const Duration(seconds: 60), 
            onTimeout: () {
               debugPrint("⚠️ Chunk ${i+1} timed out, skipping.");
               return [];
            }
          );
          
          debugPrint("✅ Chunk ${i+1} found ${recipes.length} recipes.");
          allRecipes.addAll(recipes);
        } catch (e) {
          debugPrint("⚠️ Failed to extract from chunk ${i + 1}: $e");
        }
      }

      // 5. Deduplicate (due to overlap)
      final uniqueRecipes = _deduplicateRecipes(allRecipes);
      debugPrint("📊 Total Unique Recipes Found: ${uniqueRecipes.length} (from ${allRecipes.length} raw matches)");

      if (uniqueRecipes.isEmpty) {
         throw Exception("Could not extract any recipes from the document.");
      }

      // 6. Save to Cache
      try {
        await _firestore.db.collection('cookbook_cache').doc(hash).set({
          'hash': hash,
          'createdAt': FieldValue.serverTimestamp(),
          'recipes': uniqueRecipes.map((r) => r.toMap()).toList(),
          'sourceFile': pdfFile.path.split('/').last,
        });
        debugPrint("💾 Cached ${uniqueRecipes.length} recipes for hash $hash");
      } catch (e) {
        debugPrint("⚠️ Failed to cache results: $e");
      }

      onProgress?.call('Extraction complete!');
      return uniqueRecipes;
      
    } catch (e) {
      debugPrint("❌ Extraction Error: $e");
      
      if (e.toString().contains('timeout')) {
        rethrow;
      } else if (e.toString().contains('API Key')) {
        throw Exception('Gemini API Key is missing or invalid.\n\nPlease check your .env file.');
      } else if (e.toString().contains('Failed to read PDF')) {
        throw Exception('Could not read PDF file.\n\nMake sure:\n• File is not corrupted\n• File has selectable text\n• File size is reasonable');
      }
      
      rethrow;
    }
  }

  /// Split text into overlapped chunks
  List<String> _splitTextIntoChunks(String text, int chunkSize, {int overlap = 0}) {
    List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + chunkSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      
      // Try to break at a newline to avoid cutting sentences/recipes
      int lastNewline = text.lastIndexOf('\n', end);
      if (lastNewline != -1 && lastNewline > start + overlap) {
        end = lastNewline;
      }
      
      chunks.add(text.substring(start, end));
      
      // Move start forward, but minus overlap to capture context
      start = end - overlap;
      
      // Safety check: if overlap is too big or text structure is weird, ensure we advance
      if (start >= end) start = end; 
    }
    return chunks;
  }
  
  /// Deduplicate recipes based on Title similarity
  List<Recipe> _deduplicateRecipes(List<Recipe> recipes) {
    // Simple dedupe by exact title for now. 
    // In production, we might use string similarity.
    final Map<String, Recipe> unique = {};
    for (var r in recipes) {
      final key = r.title.trim().toLowerCase();
      // Keep/Update rule: If duplicate, maybe keep the one with more ingredients?
      // For now, first come first serve, or just overwrite.
      if (!unique.containsKey(key)) {
        unique[key] = r;
      } else {
        // Optimization: If new one has more steps, take it (assuming better parse)
        if ((r.instructions?.length ?? 0) > (unique[key]?.instructions?.length ?? 0)) {
           unique[key] = r;
        }
      }
    }
    return unique.values.toList();
  }

  Future<String> _extractPdfText(File file) async {
    try {
      // Check file size (warn if > 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        debugPrint("⚠️ Large PDF file: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");
      }
      
      String text = await ReadPdfText.getPDFtext(file.path);
      
      // Clean up common PDF artifacts but preserve structure
      text = text
          .replaceAll(RegExp(r'\r\n'), '\n') // Normalize line endings
          .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Remove excessive blank lines
          .trim();
      
      return text;
    } catch (e) {
      debugPrint("❌ PDF Parse Error: $e");
      throw Exception('Failed to read PDF file: ${e.toString()}');
    }
  }
  
  // Method saveExtractedRecipes kept as is...
  Future<void> saveExtractedRecipes(String userId, List<Recipe> recipes, String sourceFileName) async {
    for (var recipe in recipes) {
      final map = recipe.toMap();
      map['sourceFile'] = sourceFileName; 
      map.removeWhere((key, value) => value == null);
      
      await _firestore.saveRecipe(map);
    }
  }
}
