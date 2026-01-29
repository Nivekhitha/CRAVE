import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
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
      // 1. Extract Text from PDF
      onProgress?.call('Reading PDF file...');
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

      // 2. Call Gemini API with timeout
      onProgress?.call('Analyzing with AI...\nThis may take 30-60 seconds.');
      final recipes = await _aiService.analyzeText(text).timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw Exception('AI analysis timed out. Please check your internet connection and try again.'),
      );

      onProgress?.call('Extraction complete!');
      return recipes;
      
    } catch (e) {
      debugPrint("❌ Extraction Error: $e");
      
      // Provide user-friendly error messages
      if (e.toString().contains('timeout')) {
        rethrow; // Already user-friendly
      } else if (e.toString().contains('API Key')) {
        throw Exception('Gemini API Key is missing or invalid.\n\nPlease check your .env file contains:\nGEMINI_API_KEY=your_key_here');
      } else if (e.toString().contains('Failed to read PDF')) {
        throw Exception('Could not read PDF file.\n\nMake sure:\n• File is not corrupted\n• File has selectable text (not just images)\n• File size is reasonable');
      }
      
      rethrow;
    }
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
