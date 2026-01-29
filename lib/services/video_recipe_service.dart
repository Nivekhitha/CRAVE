import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class VideoRecipeService {
  final String? _apiKey;

  VideoRecipeService({String? apiKey}) : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'];

  /// Extract recipe from YouTube URL using Gemini
  /// Returns Map with recipe data or null if extraction fails
  Future<Map<String, dynamic>?> extractFromYouTube(String url) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('Gemini API Key is missing. Please check your .env file.');
    }

    // Validate YouTube URL
    if (!_isValidYouTubeUrl(url)) {
      throw Exception('Invalid YouTube URL. Please provide a valid YouTube video link.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', // Try latest, falls back to gemini-1.5-flash if needed
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3, // Lower temperature for consistent JSON
      ),
    );

    final prompt = '''
Analyze this YouTube cooking video and extract the recipe.

VIDEO URL: $url

Return ONLY valid JSON (no markdown, no code blocks, no explanations):
{
  "title": "string",
  "description": "string",
  "servings": number or null,
  "prepTime": number or null,
  "cookTime": number or null,
  "ingredients": ["ingredient with quantity"],
  "instructions": ["step 1", "step 2"],
  "difficulty": "Easy" | "Medium" | "Hard" | null,
  "videoUrl": "$url",
  "videoSource": "youtube"
}

RULES:
- Include ALL ingredients mentioned in the video
- Include quantities when possible (e.g., "2 cups flour", "1 tsp salt")
- Steps must be ordered sequentially
- If no recipe detected, return: {"error":"No recipe detected"}
- prepTime and cookTime should be in minutes (numbers)
- servings should be a number
- difficulty must be exactly "Easy", "Medium", "Hard", or null

CRITICAL: Output ONLY the JSON object, nothing else.
''';

    try {
      debugPrint("🎥 Extracting recipe from YouTube: $url");
      
      final response = await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timed out. Please check your internet connection and try again.'),
      );

      if (response.text == null || response.text!.trim().isEmpty) {
        throw Exception('AI returned empty response. Please try again.');
      }

      debugPrint("✅ Received response (${response.text!.length} chars)");
      
      // Parse JSON response
      final Map<String, dynamic> recipeData = _parseJsonResponse(response.text!);
      
      // Validate extracted data
      final validationError = _validateRecipeData(recipeData);
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Check for error response
      if (recipeData.containsKey('error')) {
        throw Exception(recipeData['error'] ?? 'No recipe detected in video.');
      }

      debugPrint("✅ Successfully extracted recipe: ${recipeData['title']}");
      return recipeData;

    } catch (e) {
      String errorMessage = "Video extraction failed: $e";
      
      if (e.toString().contains("timeout")) {
        errorMessage = "Request timed out. Please check your internet connection and try again.";
      } else if (e.toString().contains("API_KEY_INVALID") || e.toString().contains("API key")) {
        errorMessage = "Invalid API Key. Please check your .env file contains a valid GEMINI_API_KEY.";
      } else if (e.toString().contains("quota") || e.toString().contains("429")) {
        errorMessage = "API quota exceeded. Please check your Google Cloud billing and API limits.";
      } else if (e.toString().contains("No valid JSON")) {
        errorMessage = "AI response format error. Please try again with a different video.";
      }
      
      debugPrint("❌ Video Extraction Error: $e");
      throw Exception(errorMessage);
    }
  }

  /// Validate YouTube URL format
  bool _isValidYouTubeUrl(String url) {
    final youtubePatterns = [
      RegExp(r'^https?://(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[\w-]+'),
      RegExp(r'^https?://(www\.)?youtube\.com/embed/[\w-]+'),
      RegExp(r'^https?://(www\.)?youtube\.com/v/[\w-]+'),
    ];
    
    return youtubePatterns.any((pattern) => pattern.hasMatch(url));
  }

  /// Parse JSON response from Gemini, handling markdown code blocks
  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    // Remove markdown code blocks if present
    jsonString = jsonString
        .replaceAll(RegExp(r'^```json\s*'), '')
        .replaceAll(RegExp(r'^```\s*'), '')
        .replaceAll(RegExp(r'\s*```$'), '')
        .trim();

    // Extract JSON object between first { and last }
    final startIndex = jsonString.indexOf('{');
    final endIndex = jsonString.lastIndexOf('}');
    
    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      throw Exception('No valid JSON found in AI response.');
    }

    jsonString = jsonString.substring(startIndex, endIndex + 1);

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  /// Validate extracted recipe data meets requirements
  String? _validateRecipeData(Map<String, dynamic> data) {
    // Check title
    if (data['title'] == null || data['title'].toString().trim().isEmpty) {
      return 'Recipe title is missing.';
    }

    // Check ingredients (need at least 2)
    final ingredients = data['ingredients'];
    if (ingredients == null || 
        !(ingredients is List) || 
        (ingredients as List).length < 2) {
      return 'Recipe must have at least 2 ingredients.';
    }

    // Check instructions (need at least 1)
    final instructions = data['instructions'];
    if (instructions == null || 
        !(instructions is List) || 
        (instructions as List).isEmpty) {
      return 'Recipe must have at least 1 instruction step.';
    }

    return null; // Valid
  }
}
