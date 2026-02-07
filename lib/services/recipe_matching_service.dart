import '../models/recipe.dart';
import '../utils/ingredient_normalizer.dart';

/// Match tier for explainable recipe matching (production-grade).
enum MatchTier {
  READY,   // 100%
  ALMOST,  // >= 70%
  LOW,     // < 70%
}

class RecipeMatch {
  final Recipe recipe;
  final double matchPercentage;
  final List<String> missingIngredients;
  final int matchingIngredientCount;
  /// Ingredients from the recipe that are in the pantry (original recipe text).
  final List<String> matchedIngredients;
  /// Tier for filtering/display: READY (100%), ALMOST (>=70%), LOW (<70%).
  final MatchTier matchTier;

  RecipeMatch({
    required this.recipe,
    required this.matchPercentage,
    required this.missingIngredients,
    required this.matchingIngredientCount,
    List<String>? matchedIngredients,
    MatchTier? matchTier,
  })  : matchedIngredients = matchedIngredients ?? [],
        matchTier = matchTier ?? _tierFromPercentage(matchPercentage);

  static MatchTier _tierFromPercentage(double p) {
    if (p >= 100) return MatchTier.READY;
    if (p >= 70) return MatchTier.ALMOST;
    return MatchTier.LOW;
  }
}

/// Production-grade, deterministic recipe matching engine.
/// Pure Dart, no UI, no AI, no network. Offline-safe.
class RecipeMatchingService {
  static final RecipeMatchingService _instance =
      RecipeMatchingService._internal();
  factory RecipeMatchingService() => _instance;
  RecipeMatchingService._internal();

  /// Returns recipes with matched/missing ingredients, percentage, and tier.
  /// Sorted by: matchPercentage desc, fewer missing, shorter cookTime.
  List<RecipeMatch> getMatches(
      List<Recipe> allRecipes, List<Map<String, dynamic>> userPantry) {
    if (allRecipes.isEmpty) return [];

    final pantryNames = userPantry
        .map((item) => item['name'] as String? ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toList();

    if (pantryNames.isEmpty) {
      return allRecipes
          .map((recipe) => RecipeMatch(
                recipe: recipe,
                matchPercentage: 0.0,
                missingIngredients: List<String>.from(recipe.ingredients),
                matchingIngredientCount: 0,
                matchedIngredients: [],
                matchTier: MatchTier.LOW,
              ))
          .toList();
    }

    final pantrySet = normalizeIngredientSet(pantryNames);

    if (userPantry.isNotEmpty && pantrySet.isEmpty) {
      return allRecipes
          .map((recipe) => RecipeMatch(
                recipe: recipe,
                matchPercentage: 0.0,
                missingIngredients: List<String>.from(recipe.ingredients),
                matchingIngredientCount: 0,
                matchedIngredients: [],
                matchTier: MatchTier.LOW,
              ))
          .toList();
    }

    final List<RecipeMatch> matches = [];

    for (final recipe in allRecipes) {
      if (recipe.ingredients.isEmpty) {
        matches.add(RecipeMatch(
          recipe: recipe,
          matchPercentage: 100.0,
          missingIngredients: [],
          matchingIngredientCount: 0,
          matchedIngredients: [],
          matchTier: MatchTier.READY,
        ));
        continue;
      }

      final recipeNormToOriginal = <String, String>{};
      for (final ing in recipe.ingredients) {
        final n = normalizeIngredient(ing);
        if (n.isNotEmpty) recipeNormToOriginal[n] = ing;
      }
      final recipeNormalized = recipeNormToOriginal.keys.toSet();
      final matchedNorm = recipeNormalized.intersection(pantrySet);
      final missingNorm = recipeNormalized.difference(pantrySet);

      final matchedIngredients =
          matchedNorm.map((n) => recipeNormToOriginal[n]!).toList();
      final missingIngredients =
          missingNorm.map((n) => recipeNormToOriginal[n]!).toList();

      final matchPercentage =
          (matchedNorm.length / recipeNormalized.length) * 100.0;
      final tier = matchPercentage >= 100
          ? MatchTier.READY
          : matchPercentage >= 70
              ? MatchTier.ALMOST
              : MatchTier.LOW;

      matches.add(RecipeMatch(
        recipe: recipe,
        matchPercentage: matchPercentage,
        missingIngredients: missingIngredients,
        matchingIngredientCount: matchedNorm.length,
        matchedIngredients: matchedIngredients,
        matchTier: tier,
      ));
    }

    _sortMatches(matches);
    return matches;
  }

  void _sortMatches(List<RecipeMatch> matches) {
    matches.sort((a, b) {
      final p = b.matchPercentage.compareTo(a.matchPercentage);
      if (p != 0) return p;
      final m = a.missingIngredients.length.compareTo(b.missingIngredients.length);
      if (m != 0) return m;
      final aTime = a.recipe.cookTime ?? a.recipe.totalTime ?? 999999;
      final bTime = b.recipe.cookTime ?? b.recipe.totalTime ?? 999999;
      return aTime.compareTo(bTime);
    });
  }
}
