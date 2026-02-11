import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class TheMealDBService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Singleton
  static final TheMealDBService _instance = TheMealDBService._internal();
  factory TheMealDBService() => _instance;
  TheMealDBService._internal();

  /// Fetch recipes by main ingredient
  Future<List<Recipe>> getRecipesByIngredient(String ingredient) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?i=$ingredient'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        
        if (meals == null) return [];

        // Determine how many detailed recipes to fetch (limit to 5 for performance)
        final limitedMeals = meals.take(5).toList();
        
        // Fetch full details for these meals in parallel
        final futures = limitedMeals.map((m) => _getRecipeDetails(m['idMeal'])).toList();
        final recipes = await Future.wait(futures);
        
        return recipes.whereType<Recipe>().toList();
      }
    } catch (e) {
      debugPrint('❌ Error fetching from TheMealDB: $e');
    }
    return [];
  }

  /// Get full recipe details by ID
  Future<Recipe?> _getRecipeDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        
        if (meals != null && meals.isNotEmpty) {
          return _parseMealToRecipe(meals.first);
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching recipe details for $id: $e');
    }
    return null;
  }

  Recipe _parseMealToRecipe(Map<String, dynamic> meal) {
    // Extract ingredients and measures
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
        final ingredient = meal['strIngredient$i'];
        final measure = meal['strMeasure$i'];
        
        if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
            String entry = ingredient.toString().trim();
            if (measure != null && measure.toString().trim().isNotEmpty) {
                entry = '$measure $entry';
            }
            ingredients.add(entry);
        }
    }

    // Split instructions into list
    final instructionsRaw = meal['strInstructions'] as String? ?? '';
    final instructionsList = instructionsRaw
        .split(RegExp(r'\r\n|\r|\n'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Recipe(
      id: "themealdb_${meal['idMeal']}", // Prefix to avoid collisions
      title: meal['strMeal'] ?? 'Unknown Recipe',
      source: 'TheMealDB',
      imageUrl: meal['strMealThumb'],
      ingredients: ingredients,
      instructions: instructionsList.join('\n\n'),
      // category: meal['strCategory'] ?? 'Main Course', // Temporarily disabled due to mismatch
      tags: meal['strTags']?.split(',') ?? [],
      sourceUrl: meal['strYoutube'],
      // area: meal['strArea'], // Cuisine (Not supported by model)
      cookTime: 30, // Default as API doesn't provide cook time
      servings: 2, // Default
      difficulty: 'Medium', // Default
    );
  }
}
