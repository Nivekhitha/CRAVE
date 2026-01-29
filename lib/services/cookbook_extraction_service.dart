import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import '../models/recipe.dart';
import 'firestore_service.dart';
import 'recipe_ai_service.dart';

class CookbookExtractionService {
  final FirestoreService _firestore = FirestoreService();
  final RecipeAiService _aiService = RecipeAiService();

  Future<List<Recipe>> extractRecipes(File pdfFile) async {
    try {
      // 1. Extract Text from PDF
      final text = await _extractPdfText(pdfFile);
      if (text.isEmpty) {
        throw Exception('No text found in PDF. It might be an image scan.');
      }
      
      debugPrint("📄 Extracted ${text.length} characters from PDF");

      // 2. Call Gemini API
      return await _aiService.analyzeText(text);
      
    } catch (e) {
      debugPrint("❌ Extraction Error: $e");
      rethrow;
    }
  }

  Future<String> _extractPdfText(File file) async {
    try {
      String text = await ReadPdfText.getPDFtext(file.path);
      // Clean up common PDF artifacts
      return text.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (e) {
      debugPrint("❌ PDF Parse Error: $e");
      throw Exception('Failed to read PDF file.');
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
