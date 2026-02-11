import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:crypto/crypto.dart'; // For SHA256
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'recipe_ai_service.dart';

class UrlRecipeExtractionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RecipeAiService _aiService = RecipeAiService();

  /// Extract recipes from an Instagram URL
  /// Returns List<Recipe> because a post might contain multiple recipes (carousel/caption)
  Future<List<Recipe>> extractFromInstagram(String url) async {
    // 0. Clean URL and Validate
    if (!url.contains('instagram.com')) {
      throw Exception('Invalid URL. Please provide a valid Instagram link.');
    }
    
    // Normalize URL (remove query params for consistent caching)
    final uri = Uri.parse(url);
    final cleanUrl = '${uri.scheme}://${uri.host}${uri.path}';
    
    try {
      // 1. Generate Hash
      final bytes = utf8.encode(cleanUrl);
      final hash = sha256.convert(bytes).toString();
      debugPrint("🔐 URL Hash: $hash ($cleanUrl)");

      // 2. Check Cache
      final cacheDoc = await _db.collection('url_recipe_cache').doc(hash).get();
      if (cacheDoc.exists && cacheDoc.data() != null) {
        final data = cacheDoc.data()!;
        if (data['recipes'] != null) {
          debugPrint("⚡ CACHE HIT: Returning stored recipes for URL");
          final List<dynamic> jsonRecipes = data['recipes'];
          return jsonRecipes.map((map) => Recipe.fromMap(map, map['id'] ?? const Uuid().v4())).toList();
        }
      }

      debugPrint("🐌 CACHE MISS: Fetching page content...");

      // 3. Fetch Page Content
      // Note: Instagram is aggressive with blocking. 
      // We try to mimic a browser User-Agent, but this is flaky for an MVP.
      final response = await http.get(
        Uri.parse(url), // Use original URL
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load page (Status: ${response.statusCode})');
      }

      // 4. Parse Metadata
      final document = parse(response.body);
      
      // Try to find og:description or json-ld
      String? description;
      
      final metaTags = document.getElementsByTagName('meta');
      for (var meta in metaTags) {
        if (meta.attributes['property'] == 'og:description' || 
            meta.attributes['name'] == 'description') {
          description = meta.attributes['content'];
          break;
        }
      }

      // Sometimes Instagram puts data in a JSON blob in <script type="application/ld+json">
      if (description == null || description.length < 50) {
         // Fallback/Desperation check for script tags if meta failed
         // Real Instagram often requires login, so this might just be the login page text.
         // For MVP, if we can't get description, we might fail or error.
         
         // Let's try to grab body text if desperate
         if (document.body != null) {
            description = document.body!.text;
         }
      }

      if (description == null || description.trim().isEmpty) {
        throw Exception('Could not extract content. The post might be private or require login.');
      }
      
      // Cleanup text 
      // Remove "View on Instagram", "Log in", generic meta headers
      String cleanText = description;
      cleanText = cleanText.replaceAll('Log in to see photos and videos from friends and discover other accounts you\'ll love.', '');
      cleanText = cleanText.trim();

      if (cleanText.length < 20) {
         throw Exception('Extracted text is too short. Is the link private?');
      }

      debugPrint("📝 Extracted Text (${cleanText.length} chars): ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...");

      // 5. AI Extraction (Reuse Chunking + RecipeAiService)
      final chunks = _splitTextIntoChunks(cleanText, 2000); // 2000 chars safety
      
      List<Recipe> allRecipes = [];
      for (var chunk in chunks) {
         try {
           final recipes = await _aiService.analyzeText(chunk);
           allRecipes.addAll(recipes);
         } catch (e) {
           debugPrint("⚠️ Chunk analysis failed: $e");
         }
      }

      if (allRecipes.isEmpty) {
        throw Exception("AI could not find any recipes in the extracted text.");
      }
      
      // 6. Save to Cache
      try {
        await _db.collection('url_recipe_cache').doc(hash).set({
          'hash': hash,
          'url': cleanUrl,
          'originalUrl': url,
          'createdAt': FieldValue.serverTimestamp(),
          'recipes': allRecipes.map((r) => r.toMap()).toList(),
        });
      } catch (e) {
        debugPrint("⚠️ Schema Cache Save Failed: $e");
      }

      return allRecipes;

    } catch (e) {
      debugPrint("❌ Instagram Extraction Error: $e");
      rethrow;
    }
  }

  /// Reuse chunking logic
  List<String> _splitTextIntoChunks(String text, int chunkSize) {
    List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + chunkSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      int lastNewline = text.lastIndexOf('\n', end);
      if (lastNewline != -1 && lastNewline > start) {
        end = lastNewline;
      }
      chunks.add(text.substring(start, end));
      start = end;
    }
    return chunks;
  }
}
