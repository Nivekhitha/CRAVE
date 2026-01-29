import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import '../models/recipe.dart';
import 'firestore_service.dart';
import 'dart:convert';

class CookbookExtractionService {
  // TODO: Replace with your actual Gemini API Key
  // Get one here: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyBV75dN8Pi7obUpSSE8UZMZMvO7u_x8dXA';
  
  final FirestoreService _firestore = FirestoreService();

  Future<List<Recipe>> extractRecipes(File pdfFile) async {
    try {
      // 1. Extract Text from PDF
      final text = await _extractPdfText(pdfFile);
      if (text.isEmpty) {
        throw Exception('No text found in PDF. It might be an image scan.');
      }
      
      debugPrint("📄 Extracted ${text.length} characters from PDF");

      // 2. Call Gemini API
      final recipes = await _analyzeWithGemini(text);
      
      // 3. Save to Firestore (optional, typically UI calls this, but we can do it here)
      // For now, we return the parsed objects so the UI can show a preview first
      return recipes;
      
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

  Future<List<Recipe>> _analyzeWithGemini(String pdfText) async {
    if (_apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception('Gemini API Key is missing. Please update CookbookExtractionService.');
    }

    final model = GenerativeModel(
      model: 'gemini-flash-latest', 
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        // responseMimeType: 'application/json', // gemini-pro 1.0 may not support this
      )
    );

    final prompt = '''
      You are a specialized recipe extraction tool. Your ONLY job is to return a JSON object containing recipes from the input text.
      
      RULES:
      1. Output MUST be valid, raw JSON.
      2. No markdown formatting (no ```json blocks).
      3. No conversational text.
      4. If the text is a Table of Contents (TOC), Index, or non-recipe text, ignore it.
      5. If no full recipes are found, return {"recipes": []}.
      
      SCHEMA:
      {
        "recipes": [
          {
            "title": "String",
            "description": "String (brief summary)",
            "ingredients": ["String (include quantity and item)"],
            "instructions": ["String (step by step)"],
            "prepTime": Number (minutes, estimate if missing),
            "cookTime": Number (minutes, estimate if missing),
            "servings": Number (estimate if missing),
            "difficulty": "Easy" | "Medium" | "Hard",
            "tags": ["String (e.g., 'Vegan', 'Dessert')"]
          }
        ]
      }
      
      debugPrint("📄 Text Preview: ${pdfText.substring(0, pdfText.length > 200 ? 200 : pdfText.length)}...");
      
      TEXT TO ANALYZE:
      ${pdfText.substring(0, pdfText.length > 100000 ? 100000 : pdfText.length)} 
      // Truncating to 100k chars 
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null) throw Exception('Empty response from AI');
      
      debugPrint("🤖 Gemini Response: ${response.text!.length > 100 ? response.text!.substring(0, 100) : response.text}...");

      String jsonString = response.text!;
      
      // Strict JSON extraction: Find content between first '{' and last '}'
      final startIndex = jsonString.indexOf('{');
      final endIndex = jsonString.lastIndexOf('}');
      
      if (startIndex != -1 && endIndex != -1) {
        jsonString = jsonString.substring(startIndex, endIndex + 1);
      } else {
        throw Exception("No valid JSON found in response. Response was: ${response.text?.substring(0, 50)}...");
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> jsonRecipes = data['recipes'] ?? [];

      return jsonRecipes.map((map) {
        return Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
          title: map['title'] ?? 'Untitled Recipe',
          source: 'cookbook',
          description: map['description'],
          ingredients: List<String>.from(map['ingredients'] ?? []),
          instructions: _formatInstructions(map['instructions']),
          prepTime: map['prepTime'] is int ? map['prepTime'] : int.tryParse(map['prepTime'].toString()),
          cookTime: map['cookTime'] is int ? map['cookTime'] : int.tryParse(map['cookTime'].toString()),
          servings: map['servings'] is int ? map['servings'] : int.tryParse(map['servings'].toString()),
          difficulty: map['difficulty'],
          tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
        );
      }).toList();

    } catch (e) {
      debugPrint("❌ Gemini API Error: $e");
      throw Exception('AI Analysis failed: $e');
    }
  }

  String _formatInstructions(dynamic input) {
    if (input is List) {
      return input.join('\n');
    }
    return input.toString();
  }
  
  Future<void> saveExtractedRecipes(String userId, List<Recipe> recipes, String sourceFileName) async {
    for (var recipe in recipes) {
      final map = recipe.toMap();
      map['sourceFile'] = sourceFileName; 
      // Clean up fields that shouldn't be null for Firestore
      map.removeWhere((key, value) => value == null);
      
      await _firestore.saveRecipe(map);
    }
  }
}
