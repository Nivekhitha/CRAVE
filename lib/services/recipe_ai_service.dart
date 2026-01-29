import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/recipe.dart';

class RecipeAiService {
  final String? _apiKey;

  RecipeAiService({String? apiKey}) : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'];

  Future<List<Recipe>> analyzeText(String text) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('Gemini API Key is missing.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
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
      
      debugPrint("📄 Text Preview: ${text.substring(0, text.length > 200 ? 200 : text.length)}...");
      
      TEXT TO ANALYZE:
      ${text.substring(0, text.length > 100000 ? 100000 : text.length)} 
      // Truncating to 100k chars 
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null) throw Exception('Empty response from AI');
      
      debugPrint("🤖 Gemini Response: ${response.text!.length > 100 ? response.text!.substring(0, 100) : response.text}...");

      return parseRecipesFromJson(response.text!);

    } catch (e) {
      String errorMessage = "AI Analysis failed: $e";
      
      if (e.toString().contains("not found") || e.toString().contains("404")) {
        errorMessage = "Error: Google Gemini Model not enabled.\n\nACTION: Go to Google Cloud Console -> Enable 'Generative Language API' for your project.";
      } else if (e.toString().contains("API_KEY_INVALID")) {
         errorMessage = "Error: Invalid API Key. Please check .env file.";
      }
      
      print("CRITICAL GEMINI ERROR: $e");
      debugPrint("❌ Gemini API Error: $e");
      throw Exception(errorMessage);
    }
  }

  /// Public for testing parsing logic in isolation
  List<Recipe> parseRecipesFromJson(String jsonString) {
      // Robust JSON extraction: Remove ```json and ``` if present
      jsonString = jsonString.replaceAll(RegExp(r'^```json\s*'), '').replaceAll(RegExp(r'\s*```$'), '');

      // Strict JSON extraction: Find content between first '{' and last '}'
      final startIndex = jsonString.indexOf('{');
      final endIndex = jsonString.lastIndexOf('}');
      
      if (startIndex != -1 && endIndex != -1) {
        jsonString = jsonString.substring(startIndex, endIndex + 1);
      } else {
        throw Exception("No valid JSON found. Raw: ${jsonString.length > 50 ? jsonString.substring(0, 50) + "..." : jsonString}");
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> jsonRecipes = data['recipes'] ?? [];

      return jsonRecipes.map((map) {
        return Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString() + (map['title']?.hashCode.toString() ?? ''),
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
  }

  String _formatInstructions(dynamic input) {
    if (input is List) {
      return input.join('\n');
    }
    return input.toString();
  }
}
