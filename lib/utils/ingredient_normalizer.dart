/// Production-grade ingredient normalization for deterministic recipe matching.
/// Pure Dart, no I/O, fully unit-testable.
library;

/// Normalizes a single ingredient string for matching.
/// Applies: lowercase, trim, remove quantities/units, singularize, synonym mapping.
String normalizeIngredient(String ingredient) {
  if (ingredient.isEmpty) return '';
  String s = ingredient.toLowerCase().trim();
  s = _stripQuantityAndUnit(s);
  s = _singularize(s);
  s = _applySynonyms(s);
  return s.trim();
}

/// Strip leading quantity and unit (e.g. "2 cups flour" -> "flour").
String _stripQuantityAndUnit(String s) {
  // Remove leading numbers, fractions, and optional units
  // Patterns: "2 cups", "1/2 tsp", "200g", "1 tbsp", "3-4", "½"
  s = s.replaceAll(RegExp(r'^\s*\d+\s*[-–—]\s*\d+\s*'), ''); // "3-4 "
  s = s.replaceAll(RegExp(r'^\s*\d+[\d./]*\s*'), '');        // "2 ", "1/2 ", "200"
  s = s.replaceAll(RegExp(r'^\s*(½|¼|¾|⅓|⅔|⅛)\s*', unicode: true), '');

  const unitPattern = r'\b(cups?|cup|tbsp|tbs|tablespoons?|tsp|teaspoons?|oz|lb|lbs|pound|pounds|'
      r'gram|grams|g\b|kg|ml|milliliters?|liters?|l\b|clove|cloves|'
      r'pinch|dash|splash|can|cans|bunch|bunches|slice|slices|'
      r'piece|pieces|stalk|stalks|head|heads|packet|packets|'
      r'large|medium|small|whole|half|handful|cup\s*of|tbsp\s*of|tsp\s*of)\b';
  s = s.replaceAll(RegExp(unitPattern, caseSensitive: false), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

/// Simple singularization for common plurals (deterministic).
String _singularize(String s) {
  if (s.length < 3) return s;
  final lower = s;
  // Common food plurals -> singular
  if (lower.endsWith('ies') && lower.length > 4) {
    final stem = lower.substring(0, lower.length - 3);
    if (_vowelConsonant(stem)) return '${stem}y'; // berries -> berry
  }
  if (lower.endsWith('es') && lower.length > 3) {
    final stem = lower.substring(0, lower.length - 2);
    if (stem.endsWith('ch') || stem.endsWith('sh') || stem.endsWith('s') || stem.endsWith('x')) {
      return stem; // tomatoes -> tomato, peaches -> peach
    }
  }
  if (lower.endsWith('s') && !lower.endsWith('ss') && lower.length > 2) {
    return lower.substring(0, lower.length - 1); // eggs -> egg, beans -> bean
  }
  return lower;
}

bool _vowelConsonant(String s) {
  if (s.length < 2) return false;
  const vowels = 'aeiou';
  return !vowels.contains(s[s.length - 1]);
}

/// Map common synonyms to a canonical form for matching.
String _applySynonyms(String s) {
  const synonyms = <String, String>{
    'tomatoes': 'tomato',
    'chilly': 'chili',
    'chillies': 'chili',
    'chillis': 'chili',
    'chilli': 'chili',
    'chilies': 'chili',
    'capsicum': 'bell pepper',
    'capsicums': 'bell pepper',
    'bell peppers': 'bell pepper',
    'olive oil': 'oil',
    'vegetable oil': 'oil',
    'cooking oil': 'oil',
    'all-purpose flour': 'flour',
    'plain flour': 'flour',
    'self-raising flour': 'flour',
    'green onions': 'scallion',
    'spring onions': 'scallion',
    'scallions': 'scallion',
    'coriander': 'cilantro',
    'courgette': 'zucchini',
    'courgettes': 'zucchini',
    'aubergine': 'eggplant',
    'aubergines': 'eggplant',
    'minced meat': 'ground meat',
    'minced beef': 'ground beef',
    'minced pork': 'ground pork',
    'baking soda': 'bicarbonate of soda',
    'bicarb': 'bicarbonate of soda',
    'vanilla extract': 'vanilla',
    'fresh basil': 'basil',
    'dried basil': 'basil',
    'fresh garlic': 'garlic',
    'garlic clove': 'garlic',
    'garlic cloves': 'garlic',
  };
  final normalized = synonyms[s] ?? s;
  return normalized;
}

/// Normalizes a list of ingredients; empty strings are omitted.
Set<String> normalizeIngredientSet(List<String> ingredients) {
  final set = <String>{};
  for (final i in ingredients) {
    final n = normalizeIngredient(i);
    if (n.isNotEmpty) set.add(n);
  }
  return set;
}
