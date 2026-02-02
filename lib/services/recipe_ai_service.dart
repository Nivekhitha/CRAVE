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
    debugPrint("🔑 Using API Key: ${key != null && key.isNotEmpty ? '${key.substring(0, 5)}...${key.substring(key.length - 4)}' : 'NULL'}");
    
    if (key == null || key.isEmpty) {
      throw Exception('Gemini API Key is missing. Please check your .env file.');
    }

    // Try available models in order of preference: standard flash first for speed/stability
    final models = ['gemini-1.5-flash', 'gemini-2.5-flash', 'gemini-1.5-pro'];
    
    Exception? lastError;
    for (final model in models) {
      try {
        debugPrint("🤖 Trying model: $model");
        return await _tryGenerate(key, model, text);
      } catch (e) {
        debugPrint("⚠️ Model $model failed: $e");
        lastError = e is Exception ? e : Exception(e.toString());
        continue;
      }
    }
    
    // If all models failed, throw the refined exception
    throw _refinedException(lastError ?? Exception('All models failed'));
  }

  Future<List<Recipe>> _tryGenerate(String key, String modelName, String text) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );


    // Truncate text if too long 
    final maxLength = 100000;
    final truncatedText = text.length > maxLength 
        ? '${text.substring(0, maxLength)}\n\n[Text truncated]'
        : text;

    final prompt = '''
You are a specialized recipe extraction tool. Extract ALL recipes from the following text and return ONLY valid JSON.

CRITICAL RULES:
1. Output MUST be valid, raw JSON (no markdown, no code blocks)
2. Start with { and end with }
3. If NO recipes found, return: {"recipes": []}

REQUIRED JSON SCHEMA:
{
  "recipes": [
    {
      "title": "Recipe Name",
      "description": "Summary",
      "ingredients": ["1 cup flour"],
      "instructions": ["Step 1"],
      "prepTime": 15,
      "cookTime": 30,
      "servings": 4,
      "difficulty": "Easy",
      "tags": ["Tag1"]
    }
  ]
}

TEXT TO ANALYZE:
$truncatedText
''';

      debugPrint("🤖 Sending request to $modelName...");
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null || response.text!.trim().isEmpty) {
        throw Exception('AI returned empty response.');
      }
      
      debugPrint("✅ Received response from $modelName");
      final recipes = parseRecipesFromJson(response.text!);
      return recipes;
  }

  Exception _refinedException(dynamic e) {
      String msg = e.toString();
      String userMessage = "Extraction Failed: $msg";
      
      if (msg.contains("not found") || msg.contains("404")) {
         // It might be a model name error or API enable error
         userMessage = "API Error (404): Model not found or API disabled.\nRaw: $msg";
      } else if (msg.contains("API_KEY_INVALID") || msg.contains("403")) {
         userMessage = "Auth Error: Invalid API Key.\nRaw: $msg";
      } else if (msg.contains("SocketException") || msg.contains("Failed to host") || msg.contains("Network")) {
         userMessage = "Network Error: check internet connection.\nRaw: $msg";
      } else if (msg.contains("quota") || msg.contains("429")) {
         userMessage = "Quota Exceeded: Try again later.";
      }
      
      return Exception(userMessage);
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

  /// Suggest recipes key on mood and ingredients
  Future<List<Recipe>> suggestRecipesByMood(String emotion, List<String> fridgeItems) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('Gemini API Key is missing. Please check your .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7, // Higher temp for creativity
      ),
    );

    final prompt = '''
You are a mood-based cooking assistant.

User emotion: $emotion
Available fridge ingredients: ${fridgeItems.join(', ')}

Suggest 2–3 recipes that:
- Match the user’s emotion
- Mainly use the provided ingredients
- Allow at most 2 extra common items (salt/oil/water are free)

Return ONLY valid JSON:
{
  "recipes": [
    {
      "title": "string",
      "whyThisFitsMood": "short explanation",
      "ingredients": ["ingredient with quantity"],
      "instructions": ["step 1", "step 2"],
      "estimatedTime": number,
      "difficulty": "Easy|Medium|Hard"
    }
  ]
}

Rules:
- No markdown
- No text outside JSON
- Comfort food for Sad/Stressed
- Quick meals for Tired
- Fun/light meals for Happy
- Cozy meals for Romantic
- If ingredients insufficient, return {"recipes":[]}
''';

    try {
      debugPrint("🎭 Suggesting recipes for mood: $emotion");
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('AI returned empty response.');
      }

      final recipes = parseRecipesFromJson(response.text!);
      return recipes;

    } catch (e) {
      debugPrint("❌ Mood Recipe Error: $e");
       // Pass through the exception message cleanly
       throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}