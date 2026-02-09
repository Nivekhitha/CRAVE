import '../models/match_result.dart';
import '../models/recipe.dart';
import 'smart_recipe_matcher.dart';

class SmartMatchingBridge {
  final SmartRecipeMatcher _matcher = SmartRecipeMatcher();

  /// Batch process recipes to find matches.
  /// userPantry: List of raw strings or maps (will handle extract).
  List<SmartMatchResult> findMatches(
      List<Recipe> allRecipes, List<Map<String, dynamic>> userPantryRaw) {
    
    // 1. Extract pantry names
    final pantryNames = userPantryRaw
        .map((item) => item['name'] as String? ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toList();

    if (pantryNames.isEmpty) return [];

    // 2. Run matching
    final List<SmartMatchResult> results = [];
    
    for (final recipe in allRecipes) {
      final match = _matcher.matchRecipeDetail(recipe, pantryNames);
      if (match.matchPercentage >= 20) { // arbitrary cutoff
        results.add(match);
      }
    }

    // 3. Sort
    results.sort((a, b) {
        // High percentage first
        int cmp = b.matchPercentage.compareTo(a.matchPercentage);
        if (cmp != 0) return cmp;
        
        // Then by missing count (fewer is better)
        return a.missingIngredients.length.compareTo(b.missingIngredients.length);
    });

    return results;
  }
}
