import '../models/recipe.dart';

/// Defines the quality tier of a match.
enum MatchTier {
  cookNow,      // >= 85% - Have almost everything
  missingFew,   // >= 60% - Missing 1-2 items or substitutions available
  needShopping, // >= 40% - Good base but need to shop
  notEnough     // < 40% - Look elsewhere
}

/// Detailed result of a smart match.
class SmartMatchResult {
  final Recipe recipe;
  final double matchPercentage;
  final MatchTier tier;
  
  /// Ingredients user has exactly.
  final List<String> usedIngredients;
  
  /// Ingredients user is missing.
  final List<String> missingIngredients;
  
  /// Ingredients user has a substitution for.
  /// Key: Recipe ingredient, Value: User's ingredient used as sub.
  final Map<String, String> substitutions;

  /// Human-readable explanation of the match quality or substitutions.
  /// e.g. "Use Greek Yogurt instead of Sour Cream"
  final List<String> suggestions;

  SmartMatchResult({
    required this.recipe,
    required this.matchPercentage,
    required this.tier,
    required this.usedIngredients,
    required this.missingIngredients,
    this.substitutions = const {},
    this.suggestions = const [],
  });

  /// Factory to create from raw percentage
  factory SmartMatchResult.fromPercentage({
    required Recipe recipe,
    required double percentage,
    required List<String> missing,
    List<String> used = const [],
    Map<String, String> substitutions = const {},
    List<String> suggestions = const [],
  }) {
    return SmartMatchResult(
      recipe: recipe,
      matchPercentage: percentage,
      tier: _tierFromPercentage(percentage),
      usedIngredients: used,
      missingIngredients: missing,
      substitutions: substitutions,
      suggestions: suggestions,
    );
  }

  static MatchTier _tierFromPercentage(double p) {
    if (p >= 85) return MatchTier.cookNow;
    if (p >= 60) return MatchTier.missingFew;
    if (p >= 40) return MatchTier.needShopping;
    return MatchTier.notEnough;
  }
}
