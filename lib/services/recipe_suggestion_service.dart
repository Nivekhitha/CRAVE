import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../services/recipe_matching_service.dart';
import '../services/firestore_service.dart';
import '../services/seed_data_service.dart';

class RecipeSuggestionService extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final RecipeMatchingService _matcher = RecipeMatchingService();
  final SeedDataService _seedService = SeedDataService();

  List<Recipe> _allRecipes = [];
  List<RecipeMatch> _currentMatches = [];
  bool _isLoading = false;
  bool _hasSeededInitialRecipes = false;

  // Getters
  List<RecipeMatch> get currentMatches => _currentMatches;
  bool get isLoading => _isLoading;
  bool get hasRecipes => _allRecipes.isNotEmpty;

  /// Initialize the service and load recipes
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadRecipes();
      await _ensureMinimumRecipes();
    } catch (e) {
      debugPrint('❌ Error initializing RecipeSuggestionService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all available recipes from Firestore
  Future<void> _loadRecipes() async {
    try {
      final snapshot = await _firestore.db
          .collection('recipes')
          .limit(100) // Reasonable limit for production
          .get();

      _allRecipes = snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();

      debugPrint('📚 Loaded ${_allRecipes.length} recipes');
    } catch (e) {
      debugPrint('❌ Error loading recipes: $e');
      _allRecipes = [];
    }
  }

  /// Ensure we have minimum recipes for good user experience
  Future<void> _ensureMinimumRecipes() async {
    const minRecipes = 10;
    
    if (_allRecipes.length < minRecipes && !_hasSeededInitialRecipes) {
      debugPrint('🌱 Seeding initial recipes for better UX...');
      try {
        await _seedService.seedRecipes();
        await _loadRecipes(); // Reload after seeding
        _hasSeededInitialRecipes = true;
        debugPrint('✅ Seeded recipes successfully');
      } catch (e) {
        debugPrint('⚠️ Failed to seed recipes: $e');
      }
    }
  }

  /// Get recipe suggestions based on pantry ingredients
  List<RecipeMatch> getSuggestions(List<Map<String, dynamic>> pantryItems) {
    if (_allRecipes.isEmpty || pantryItems.isEmpty) {
      _currentMatches = [];
      return _currentMatches;
    }

    // Run matching algorithm
    final matches = _matcher.getMatches(_allRecipes, pantryItems);
    
    // Filter and sort for best suggestions
    _currentMatches = matches
        .where((match) => match.matchPercentage > 0) // Only show recipes with some match
        .take(20) // Limit to top 20 for performance
        .toList();

    debugPrint('🎯 Found ${_currentMatches.length} recipe suggestions');
    
    // Log top matches for debugging
    if (_currentMatches.isNotEmpty) {
      final topMatches = _currentMatches.take(3).map((m) => 
        '${m.recipe.title} (${m.matchPercentage.round()}%)'
      ).join(', ');
      debugPrint('🏆 Top matches: $topMatches');
    }

    notifyListeners();
    return _currentMatches;
  }

  /// Get suggestions by match quality
  Map<String, List<RecipeMatch>> getSuggestionsByQuality(List<Map<String, dynamic>> pantryItems) {
    final suggestions = getSuggestions(pantryItems);
    
    return {
      'perfect': suggestions.where((m) => m.matchPercentage >= 90).toList(),
      'great': suggestions.where((m) => m.matchPercentage >= 70 && m.matchPercentage < 90).toList(),
      'good': suggestions.where((m) => m.matchPercentage >= 50 && m.matchPercentage < 70).toList(),
      'possible': suggestions.where((m) => m.matchPercentage > 0 && m.matchPercentage < 50).toList(),
    };
  }

  /// Get quick suggestions (recipes with 3 or fewer missing ingredients)
  List<RecipeMatch> getQuickSuggestions(List<Map<String, dynamic>> pantryItems) {
    final suggestions = getSuggestions(pantryItems);
    return suggestions
        .where((match) => match.missingIngredients.length <= 3)
        .take(5)
        .toList();
  }

  /// Get suggestions for a specific meal type
  List<RecipeMatch> getSuggestionsByMealType(
    List<Map<String, dynamic>> pantryItems, 
    String mealType
  ) {
    final suggestions = getSuggestions(pantryItems);
    return suggestions
        .where((match) => 
          match.recipe.tags?.any((tag) => 
            tag.toLowerCase().contains(mealType.toLowerCase())
          ) ?? false
        )
        .toList();
  }

  /// Add a new recipe and refresh suggestions
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _firestore.saveRecipe(recipe.toMap());
      _allRecipes.add(recipe);
      debugPrint('✅ Added new recipe: ${recipe.title}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error adding recipe: $e');
      rethrow;
    }
  }

  /// Refresh recipes from database
  Future<void> refreshRecipes() async {
    await _loadRecipes();
    notifyListeners();
  }

  /// Get ingredient suggestions based on current recipes
  List<String> getIngredientSuggestions(List<Map<String, dynamic>> currentPantry) {
    if (_allRecipes.isEmpty) return [];

    // Find most common ingredients across all recipes
    final ingredientFrequency = <String, int>{};
    final currentIngredients = currentPantry
        .map((item) => (item['name'] as String? ?? '').toLowerCase())
        .toSet();

    for (final recipe in _allRecipes) {
      for (final ingredient in recipe.ingredients) {
        final normalizedIngredient = ingredient.toLowerCase().trim();
        if (!currentIngredients.contains(normalizedIngredient)) {
          ingredientFrequency[ingredient] = 
              (ingredientFrequency[ingredient] ?? 0) + 1;
        }
      }
    }

    // Return top suggestions
    final suggestions = ingredientFrequency.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    return suggestions
        .take(10)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get recipes that would become cookable with one more ingredient
  List<Map<String, dynamic>> getOneIngredientAway(List<Map<String, dynamic>> pantryItems) {
    final suggestions = getSuggestions(pantryItems);
    
    return suggestions
        .where((match) => match.missingIngredients.length == 1)
        .map((match) => {
          'recipe': match.recipe,
          'missingIngredient': match.missingIngredients.first,
          'matchPercentage': match.matchPercentage,
        })
        .toList();
  }

  /// Clear current matches (useful for testing)
  void clearMatches() {
    _currentMatches = [];
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}