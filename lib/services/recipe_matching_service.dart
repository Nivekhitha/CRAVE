import '../models/recipe.dart';
import '../models/ingredient.dart';

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
  static final RecipeMatchingService _instance = RecipeMatchingService._internal();
  factory RecipeMatchingService() => _instance;
  RecipeMatchingService._internal();

  /// Main matching algorithm
  List<RecipeMatch> getMatches(List<Recipe> allRecipes, List<Map<String, dynamic>> userPantry) {
    if (allRecipes.isEmpty) return [];

    // 1. Normalize user ingredients for faster lookup
    // complex fuzzy matching can be expensive, so we start with simple lower-case set
    final userIngredients = userPantry
        .map((item) => (item['name'] as String).toLowerCase().trim())
        .toSet();

    final List<RecipeMatch> matches = [];

    for (var recipe in allRecipes) {
      if (recipe.ingredients.isEmpty) continue;

      int matchCount = 0;
      List<String> missing = [];

      for (var ingredient in recipe.ingredients) {
        final recipeIng = ingredient.toLowerCase().trim();
        
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

      double percentage = (matchCount / recipe.ingredients.length) * 100;
      
      // Filter out low matches? (Optional, maybe keep all for now)
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
