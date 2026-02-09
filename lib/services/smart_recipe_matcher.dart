import '../data/category_database.dart';
import '../data/substitution_database.dart';
import '../models/match_result.dart';
import '../models/recipe.dart';
import '../utils/ingredient_normalizer.dart';

class SmartRecipeMatcher {
  // Score Weights / Penalties
  // static const double _exactMatchBonus = 10.0; // Unused
  static const double _substitutionPenalty = 0.8; // Match counts as 80%
  // static const double _categoryMatchPenalty = 0.5; // Unused
  
  // Ingredient Weights (Points)
  static const int _mainIngredientPoints = 50;
  static const int _secondaryIngredientPoints = 15;
  static const int _garnishPoints = 5;

  /// Main entry point for matching a single recipe against user ingredients.
  SmartMatchResult? matchRecipe(Recipe recipe, List<String> userPantry) {
      final result = matchRecipeDetail(recipe, userPantry);
      // Filter lowest matches
      if (result.matchPercentage < 20) return null;
      return result;
  }
    
  SmartMatchResult matchRecipeDetail(Recipe recipe, List<String> userPantry) {
     if (recipe.ingredients.isEmpty) {
        return SmartMatchResult(
            recipe: recipe,
            matchPercentage: 0,
            tier: MatchTier.notEnough,
            usedIngredients: [],
            missingIngredients: [],
        );
     }

    // 1. Normalize
    final pantrySet = normalizeIngredientSet(userPantry);
    
    double currentScore = 0;
    double maxPossibleScore = 0;
    
    final usedIngredients = <String>[];
    final missingIngredients = <String>[];
    final substitutionsMap = <String, String>{};
    final suggestionsList = <String>[];

    int index = 0;
    for (final originalIng in recipe.ingredients) {
      final normalizedIng = normalizeIngredient(originalIng);
      if (normalizedIng.isEmpty) continue;

      int points = _getIngredientWeight(normalizedIng, index, recipe.ingredients.length);
      maxPossibleScore += points;
      index++;

      // Exact
      if (pantrySet.contains(normalizedIng)) {
          currentScore += points;
          usedIngredients.add(originalIng);
          continue;
      }
      
      // Fuzzy
      String? fuzzyMatch = _findFuzzyMatch(normalizedIng, pantrySet);
      if (fuzzyMatch != null) {
          currentScore += points;
          usedIngredients.add(originalIng);
          continue;
      }

      // Substitution
      String? subMatch = _findSubstitutionMatch(normalizedIng, pantrySet);
      if (subMatch != null) {
          currentScore += (points * _substitutionPenalty);
          usedIngredients.add(originalIng); 
          substitutionsMap[originalIng] = subMatch;
          suggestionsList.add("Use $subMatch instead of $originalIng");
          continue;
      }

      missingIngredients.add(originalIng);
    }

    double percentage = 0;
    if (maxPossibleScore > 0) {
        percentage = (currentScore / maxPossibleScore) * 100.0;
    }

    // Clamp to 100
    if (percentage > 100) percentage = 100;

    return SmartMatchResult.fromPercentage(
        recipe: recipe,
        percentage: percentage,
        missing: missingIngredients,
        used: usedIngredients,
        substitutions: substitutionsMap,
        suggestions: suggestionsList,
    );
  }

  // --- Helpers ---

  int _getIngredientWeight(String ingredient, int index, int total) {
      final category = ingredientCategories[ingredient];
      
      if (category == IngredientCategory.pantry || category == IngredientCategory.liquid) {
          if (['salt', 'pepper', 'water', 'oil'].contains(ingredient)) return 1; 
          return _garnishPoints;
      }
      
      if (category == IngredientCategory.protein || category == IngredientCategory.grain) {
          return _mainIngredientPoints;
      }
      
      if (index < (total * 0.3).ceil()) return _mainIngredientPoints; 
      if (index >= (total * 0.8).floor()) return _garnishPoints; 
      
      return _secondaryIngredientPoints;
  }

  String? _findFuzzyMatch(String recipeIng, Set<String> pantrySet) {
      for (final pantryItem in pantrySet) {
          if (recipeIng.contains(pantryItem)) return pantryItem;
          if (pantryItem.contains(recipeIng)) return pantryItem;
      }
      return null;
  }

  String? _findSubstitutionMatch(String recipeIng, Set<String> pantrySet) {
      final options = commonSubstitutions[recipeIng];
      if (options == null) return null;
      
      for (final opt in options) {
           if (pantrySet.contains(opt)) return opt;
           if (_findFuzzyMatch(opt, pantrySet) != null) return opt;
      }
      return null;
  }
  
  Set<String> normalizeIngredientSet(List<String> ingredients) {
      final set = <String>{};
      for (final i in ingredients) {
        final n = normalizeIngredient(i);
        if (n.isNotEmpty) set.add(n);
      }
      return set;
  }
  
  Map<String, String> _mapIngredients(List<String> ingredients) {
      final map = <String, String>{};
      for (final i in ingredients) {
          map[normalizeIngredient(i)] = i;
      }
      return map;
  }
}
