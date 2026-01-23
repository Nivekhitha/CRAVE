import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/grocery_item.dart';

class HiveService {
  // Box names
  static const String ingredientsBox = 'ingredients';
  static const String recipesBox = 'recipes';
  static const String groceryBox = 'grocery';
  static const String settingsBox = 'settings';

  // Singleton pattern
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Initialization flag
  bool _isInitialized = false;

  /// Initialize Hive (call once in main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(IngredientAdapter());
    Hive.registerAdapter(RecipeAdapter());
    Hive.registerAdapter(GroceryItemAdapter());

    // Open boxes
    await Hive.openBox<Ingredient>(ingredientsBox);
    await Hive.openBox<Recipe>(recipesBox);
    await Hive.openBox<GroceryItem>(groceryBox);
    await Hive.openBox(settingsBox);

    _isInitialized = true;
    print('✅ Hive initialized successfully');
  }

  // ========================================
  // INGREDIENTS
  // ========================================

  Box<Ingredient> get _ingredientsBox => Hive.box<Ingredient>(ingredientsBox);

  /// Add ingredient to fridge/pantry
  Future<void> addIngredient(Ingredient ingredient) async {
    await _ingredientsBox.put(ingredient.id, ingredient);
    print('Added ingredient: ${ingredient.name}');
  }

  /// Get all ingredients
  List<Ingredient> getAllIngredients() {
    return _ingredientsBox.values.toList();
  }

  /// Get ingredients by category
  List<Ingredient> getIngredientsByCategory(String category) {
    return _ingredientsBox.values
        .where((i) => i.category == category)
        .toList();
  }

  /// Search ingredients
  List<Ingredient> searchIngredients(String query) {
    if (query.isEmpty) return getAllIngredients();
    return _ingredientsBox.values
        .where((i) => i.matchesQuery(query))
        .toList();
  }

  /// Update ingredient
  Future<void> updateIngredient(Ingredient ingredient) async {
    await ingredient.save();
    print('Updated ingredient: ${ingredient.name}');
  }

  /// Delete ingredient
  Future<void> deleteIngredient(String id) async {
    await _ingredientsBox.delete(id);
    print('Deleted ingredient with id: $id');
  }

  /// Get ingredient by ID
  Ingredient? getIngredient(String id) {
    return _ingredientsBox.get(id);
  }

  /// Clear all ingredients
  Future<void> clearAllIngredients() async {
    await _ingredientsBox.clear();
    print('Cleared all ingredients');
  }

  // ========================================
  // RECIPES
  // ========================================

  Box<Recipe> get _recipesBox => Hive.box<Recipe>(recipesBox);

  /// Add recipe
  Future<void> addRecipe(Recipe recipe) async {
    await _recipesBox.put(recipe.id, recipe);
    print('Added recipe: ${recipe.title}');
  }

  /// Get all recipes
  List<Recipe> getAllRecipes() {
    return _recipesBox.values.toList();
  }

  /// Get free recipes only (for non-premium users)
  List<Recipe> getFreeRecipes() {
    return _recipesBox.values.where((r) => !r.isPremium).toList();
  }

  /// Get premium recipes
  List<Recipe> getPremiumRecipes() {
    return _recipesBox.values.where((r) => r.isPremium).toList();
  }

  /// Get recipes by tag
  List<Recipe> getRecipesByTag(String tag) {
    return _recipesBox.values
        .where((r) => r.tags?.contains(tag) ?? false)
        .toList();
  }

  /// Search recipes
  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return getAllRecipes();
    return _recipesBox.values
        .where((r) => r.matchesQuery(query))
        .toList();
  }

  /// Get recipe by ID
  Recipe? getRecipe(String id) {
    return _recipesBox.get(id);
  }

  /// Update recipe
  Future<void> updateRecipe(Recipe recipe) async {
    await recipe.save();
    print('Updated recipe: ${recipe.title}');
  }

  /// Delete recipe
  Future<void> deleteRecipe(String id) async {
    await _recipesBox.delete(id);
    print('Deleted recipe with id: $id');
  }

  /// Mark recipe as cooked
  Future<void> markRecipeAsCooked(String id) async {
    final recipe = _recipesBox.get(id);
    if (recipe != null) {
      recipe.markAsCooked();
      print('Marked recipe as cooked: ${recipe.title}');
    }
  }

  /// Get recently cooked recipes
  List<Recipe> getRecentlyCookedRecipes({int limit = 10}) {
    final recipes = _recipesBox.values.where((r) => r.lastCookedAt != null).toList();
    recipes.sort((a, b) => b.lastCookedAt!.compareTo(a.lastCookedAt!));
    return recipes.take(limit).toList();
  }

  /// Clear all recipes
  Future<void> clearAllRecipes() async {
    await _recipesBox.clear();
    print('Cleared all recipes');
  }

  // ========================================
  // GROCERY LIST
  // ========================================

  Box<GroceryItem> get _groceryBox => Hive.box<GroceryItem>(groceryBox);

  /// Add item to grocery list
  Future<void> addGroceryItem(GroceryItem item) async {
    await _groceryBox.put(item.id, item);
    print('Added grocery item: ${item.name}');
  }

  /// Get all grocery items
  List<GroceryItem> getAllGroceryItems() {
    return _groceryBox.values.toList();
  }

  /// Get unchecked grocery items
  List<GroceryItem> getUncheckedGroceryItems() {
    return _groceryBox.values.where((i) => !i.isChecked).toList();
  }

  /// Get checked grocery items
  List<GroceryItem> getCheckedGroceryItems() {
    return _groceryBox.values.where((i) => i.isChecked).toList();
  }

  /// Toggle grocery item checked status
  Future<void> toggleGroceryItem(String id) async {
    final item = _groceryBox.get(id);
    if (item != null) {
      item.toggle();
      print('Toggled grocery item: ${item.name} -> ${item.isChecked}');
    }
  }

  /// Update grocery item
  Future<void> updateGroceryItem(GroceryItem item) async {
    await item.save();
    print('Updated grocery item: ${item.name}');
  }

  /// Delete grocery item
  Future<void> deleteGroceryItem(String id) async {
    await _groceryBox.delete(id);
    print('Deleted grocery item with id: $id');
  }

  /// Clear checked items from grocery list
  Future<void> clearCheckedGroceryItems() async {
    final checked = getCheckedGroceryItems();
    for (final item in checked) {
      await item.delete();
    }
    print('Cleared ${checked.length} checked grocery items');
  }

  /// Clear all grocery items
  Future<void> clearAllGroceryItems() async {
    await _groceryBox.clear();
    print('Cleared all grocery items');
  }

  /// Add multiple grocery items (for recipe missing ingredients)
  Future<void> addMultipleGroceryItems(List<GroceryItem> items) async {
    for (final item in items) {
      await addGroceryItem(item);
    }
    print('Added ${items.length} items to grocery list');
  }

  // ========================================
  // SETTINGS & APP STATE
  // ========================================

  Box get _settingsBox => Hive.box(settingsBox);

  /// Check if user is premium
  bool get isPremiumUser => _settingsBox.get('isPremium', defaultValue: false);

  /// Set premium user status
  Future<void> setPremiumUser(bool value) async {
    await _settingsBox.put('isPremium', value);
    print('Premium status set to: $value');
  }

  /// Get free recipe limit
  int get freeRecipeLimit => 10; // Free users can save max 10 recipes

  /// Check if user can add more recipes
  bool canAddRecipe() {
    if (isPremiumUser) return true;
    final freeRecipes = getFreeRecipes();
    return freeRecipes.length < freeRecipeLimit;
  }

  /// Get app settings
  Map<String, dynamic> getSettings() {
    return {
      'isPremium': isPremiumUser,
      'freeRecipeLimit': freeRecipeLimit,
      'totalRecipes': _recipesBox.length,
      'totalIngredients': _ingredientsBox.length,
      'totalGroceryItems': _groceryBox.length,
    };
  }

  /// Clear all app data (for testing or user reset)
  Future<void> clearAllData() async {
    await _ingredientsBox.clear();
    await _recipesBox.clear();
    await _groceryBox.clear();
    await _settingsBox.clear();
    print('🗑️ All app data cleared');
  }

  // ========================================
  // RECIPE MATCHING LOGIC (Core Feature!)
  // ========================================

  /// Calculate match percentage for a recipe
  double calculateRecipeMatch(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return 0.0;

    final availableIngredients = getAllIngredients();
    final ingredientNames = availableIngredients
        .map((i) => i.name.toLowerCase())
        .toSet();

    int matchCount = 0;
    for (final ingredient in recipe.ingredients) {
      final ingredientLower = ingredient.toLowerCase();
      
      // Check if any available ingredient matches
      if (ingredientNames.any((name) =>
          ingredientLower.contains(name) || name.contains(ingredientLower))) {
        matchCount++;
      }
    }

    return (matchCount / recipe.ingredients.length) * 100;
  }

  /// Get missing ingredients for a recipe
  List<String> getMissingIngredients(Recipe recipe) {
    final availableIngredients = getAllIngredients();
    final ingredientNames = availableIngredients
        .map((i) => i.name.toLowerCase())
        .toSet();

    return recipe.ingredients.where((ingredient) {
      final ingredientLower = ingredient.toLowerCase();
      return !ingredientNames.any((name) =>
          ingredientLower.contains(name) || name.contains(ingredientLower));
    }).toList();
  }

  /// Get recipes sorted by match percentage
  List<MapEntry<Recipe, double>> getRecipesSortedByMatch() {
    final recipes = getAllRecipes();
    final matches = <Recipe, double>{};

    for (final recipe in recipes) {
      matches[recipe] = calculateRecipeMatch(recipe);
    }

    final sortedEntries = matches.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries;
  }

  /// Get top N recipe matches
  List<MapEntry<Recipe, double>> getTopRecipeMatches({int limit = 5}) {
    final sorted = getRecipesSortedByMatch();
    return sorted.take(limit).toList();
  }

  // ========================================
  // STATISTICS & ANALYTICS
  // ========================================

  Map<String, dynamic> getStatistics() {
    final recipes = getAllRecipes();
    final cookedRecipes = recipes.where((r) => r.cookCount > 0).toList();

    return {
      'totalRecipes': recipes.length,
      'premiumRecipes': getPremiumRecipes().length,
      'freeRecipes': getFreeRecipes().length,
      'cookedRecipes': cookedRecipes.length,
      'totalCookCount': cookedRecipes.fold<int>(0, (sum, r) => sum + r.cookCount),
      'totalIngredients': _ingredientsBox.length,
      'groceryItems': _groceryBox.length,
      'checkedGroceryItems': getCheckedGroceryItems().length,
      'isPremium': isPremiumUser,
    };
  }
}
