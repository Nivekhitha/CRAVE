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
      throw Exception('Gemini API Key is missing. Please check your .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3, // Lower temperature for more consistent JSON output
      )
    );

    // Truncate text if too long (Gemini has token limits)
    final maxLength = 100000;
    final truncatedText = text.length > maxLength 
        ? '${text.substring(0, maxLength)}\n\n[Text truncated - showing first ${maxLength} characters]'
        : text;

    final prompt = '''
You are a specialized recipe extraction tool. Extract ALL recipes from the following text and return ONLY valid JSON.

CRITICAL RULES:
1. Output MUST be valid, raw JSON (no markdown, no code blocks, no explanations)
2. Start with { and end with }
3. Extract EVERY complete recipe you find
4. If text contains Table of Contents, Index, or non-recipe content, skip those sections
5. If NO recipes found, return: {"recipes": []}

REQUIRED JSON SCHEMA:
{
  "recipes": [
    {
      "title": "Recipe Name (required)",
      "description": "Brief 1-2 sentence summary (optional)",
      "ingredients": ["2 cups flour", "1 tsp salt", "etc - include quantities"],
      "instructions": ["Step 1 description", "Step 2 description", "etc"],
      "prepTime": 15,
      "cookTime": 30,
      "servings": 4,
      "difficulty": "Easy" or "Medium" or "Hard",
      "tags": ["Vegan", "Dessert", "etc"]
    }
  ]
}

VALIDATION:
- Each recipe MUST have: title, at least 2 ingredients, at least 1 instruction
- prepTime, cookTime, servings should be numbers (minutes/people)
- difficulty must be "Easy", "Medium", or "Hard" (or null)

TEXT TO ANALYZE:
$truncatedText
''';

    try {
      debugPrint("🤖 Sending ${truncatedText.length} characters to Gemini...");
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null || response.text!.trim().isEmpty) {
        throw Exception('AI returned empty response. Please try again.');
      }
      
      debugPrint("✅ Received response (${response.text!.length} chars)");
      debugPrint("📝 Response preview: ${response.text!.substring(0, response.text!.length > 200 ? 200 : response.text!.length)}...");

      final recipes = parseRecipesFromJson(response.text!);
      
      if (recipes.isEmpty) {
        debugPrint("⚠️ No recipes extracted from response");
      } else {
        debugPrint("✅ Successfully extracted ${recipes.length} recipe(s)");
      }
      
      return recipes;

    } catch (e) {
      String errorMessage = "AI Analysis failed: $e";
      
      if (e.toString().contains("not found") || e.toString().contains("404")) {
        errorMessage = "Gemini API not enabled.\n\nPlease enable 'Generative Language API' in Google Cloud Console.";
      } else if (e.toString().contains("API_KEY_INVALID") || e.toString().contains("API key")) {
         errorMessage = "Invalid API Key.\n\nPlease check your .env file contains a valid GEMINI_API_KEY.";
      } else if (e.toString().contains("quota") || e.toString().contains("429")) {
        errorMessage = "API quota exceeded.\n\nPlease check your Google Cloud billing and API limits.";
      } else if (e.toString().contains("No valid JSON")) {
        errorMessage = "AI response format error.\n\nPlease try again with a clearer PDF.";
      }
      
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
