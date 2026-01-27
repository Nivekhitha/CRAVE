import '../models/recipe.dart';
import '../utils/performance_monitor.dart';
import 'package:flutter/foundation.dart';

class RecipeMatch {
  final Recipe recipe;
  final double matchPercentage;
  final List<String> missingIngredients;
  final int matchingIngredientCount;

  RecipeMatch({
    required this.recipe,
    required this.matchPercentage,
    required this.missingIngredients,
    required this.matchingIngredientCount,
  });
}

class RecipeMatchingService {
  // Singleton
  static final RecipeMatchingService _instance =
      RecipeMatchingService._internal();
  factory RecipeMatchingService() => _instance;
  RecipeMatchingService._internal();

  /// Main matching algorithm
  List<RecipeMatch> getMatches(
      List<Recipe> allRecipes, List<Map<String, dynamic>> userPantry) {
    // Edge Case 1: Empty recipes list
    if (allRecipes.isEmpty) return [];

    // Edge Case 2: Empty pantry - all recipes will have 0% match
    if (userPantry.isEmpty) {
      return allRecipes
          .map((recipe) => RecipeMatch(
                recipe: recipe,
                matchPercentage: 0.0,
                missingIngredients: List<String>.from(recipe.ingredients),
                matchingIngredientCount: 0,
              ))
          .toList();
    }

    // 1. Normalize user ingredients for faster lookup
    // complex fuzzy matching can be expensive, so we start with simple lower-case set
    final userIngredients = userPantry
        .map((item) => (item['name'] as String? ?? '').toLowerCase().trim())
        .where((name) => name.isNotEmpty) // Filter out empty names
        .toSet();

    // Edge Case 3: All pantry items have empty names
    if (userIngredients.isEmpty) {
      return allRecipes
          .map((recipe) => RecipeMatch(
                recipe: recipe,
                matchPercentage: 0.0,
                missingIngredients: List<String>.from(recipe.ingredients),
                matchingIngredientCount: 0,
              ))
          .toList();
    }

    final List<RecipeMatch> matches = [];

    for (var recipe in allRecipes) {
      // Edge Case 4: Recipe with no ingredients
      if (recipe.ingredients.isEmpty) {
        matches.add(RecipeMatch(
          recipe: recipe,
          matchPercentage: 100.0, // No ingredients needed = 100% match
          missingIngredients: [],
          matchingIngredientCount: 0,
        ));
        continue;
      }

      int matchCount = 0;
      List<String> missing = [];

      for (var ingredient in recipe.ingredients) {
        final recipeIng = ingredient.toLowerCase().trim();

        // Skip empty ingredients
        if (recipeIng.isEmpty) continue;

        // Fuzzy Match Strategy (MVP):
        // Check if pantry item *contains* recipe ingredient OR vice-versa
        // e.g. Pantry: "Chicken Breast" matches Recipe: "Chicken"
        bool isMatch = false;

        if (userIngredients.contains(recipeIng)) {
          isMatch = true;
        } else {
          // Fallback to "contains" check
          for (var userIng in userIngredients) {
            if (userIng.contains(recipeIng) || recipeIng.contains(userIng)) {
              isMatch = true;
              break;
            }
          }
        }

        if (isMatch) {
          matchCount++;
        } else {
          missing.add(ingredient);
        }
      }

      // Edge Case 5: Avoid division by zero
      double percentage = recipe.ingredients.isNotEmpty
          ? (matchCount / recipe.ingredients.length) * 100
          : 100.0;

      matches.add(RecipeMatch(
        recipe: recipe,
        matchPercentage: percentage,
        missingIngredients: missing,
        matchingIngredientCount: matchCount,
      ));
    }

    // Sort by Match Percentage (Highest first)
    matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

    return matches;
  }
}
