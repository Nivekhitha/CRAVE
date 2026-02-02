import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/recipe_suggestion_service.dart';

class MealPlanningService extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  final RecipeSuggestionService _suggestionService = RecipeSuggestionService();

  List<MealPlan> _mealPlans = [];
  bool _isLoading = false;
  DateTime _currentWeekStart = DateTime.now();

  // Getters
  List<MealPlan> get mealPlans => _mealPlans;
  bool get isLoading => _isLoading;
  DateTime get currentWeekStart => _currentWeekStart;

  /// Initialize the service
  Future<void> initialize() async {
    await loadMealPlans();
  }

  /// Load meal plans for current week
  Future<void> loadMealPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _auth.userId;
      if (userId == null) return;

      final weekStart = _getWeekStart(_currentWeekStart);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final snapshot = await _firestore.db
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('date', isLessThan: Timestamp.fromDate(weekEnd))
          .orderBy('date')
          .get();

      _mealPlans = snapshot.docs
          .map((doc) => MealPlan.fromMap(doc.data(), doc.id))
          .toList();

      debugPrint('📅 Loaded ${_mealPlans.length} meal plans for week');
    } catch (e) {
      debugPrint('❌ Error loading meal plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new meal plan for a specific date
  Future<MealPlan> createMealPlan(DateTime date) async {
    final userId = _auth.userId;
    if (userId == null) throw Exception('User not authenticated');

    final mealPlan = MealPlan(
      id: _generateMealPlanId(date),
      date: _normalizeDate(date),
      meals: [],
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.db
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .doc(mealPlan.id)
          .set(mealPlan.toMap());

      _mealPlans.add(mealPlan);
      _sortMealPlans();
      notifyListeners();

      debugPrint('✅ Created meal plan for ${date.toIso8601String()}');
      return mealPlan;
    } catch (e) {
      debugPrint('❌ Error creating meal plan: $e');
      rethrow;
    }
  }

  /// Add a meal to a specific date
  Future<void> addMealToPlan(DateTime date, MealType mealType, Recipe recipe, {int? servings}) async {
    final mealPlan = await _getOrCreateMealPlan(date);
    
    final plannedMeal = PlannedMeal(
      id: _generateMealId(),
      mealType: mealType,
      recipe: recipe,
      servings: servings ?? 1,
    );

    mealPlan.addMeal(plannedMeal);
    await _saveMealPlan(mealPlan);
    
    debugPrint('✅ Added ${recipe.title} to ${mealType.displayName} on ${date.toIso8601String()}');
  }

  /// Add a custom meal (without recipe) to a specific date
  Future<void> addCustomMealToPlan(DateTime date, MealType mealType, String mealName, {DateTime? scheduledTime}) async {
    final mealPlan = await _getOrCreateMealPlan(date);
    
    final plannedMeal = PlannedMeal(
      id: _generateMealId(),
      mealType: mealType,
      customMealName: mealName,
      scheduledTime: scheduledTime,
    );

    mealPlan.addMeal(plannedMeal);
    await _saveMealPlan(mealPlan);
    
    debugPrint('✅ Added custom meal "$mealName" to ${mealType.displayName} on ${date.toIso8601String()}');
  }

  /// Remove a meal from plan
  Future<void> removeMealFromPlan(DateTime date, String mealId) async {
    final mealPlan = getMealPlanForDate(date);
    if (mealPlan == null) return;

    mealPlan.removeMeal(mealId);
    await _saveMealPlan(mealPlan);
    
    debugPrint('✅ Removed meal from plan');
  }

  /// Mark a meal as cooked
  Future<void> markMealAsCooked(DateTime date, String mealId) async {
    final mealPlan = getMealPlanForDate(date);
    if (mealPlan == null) return;

    final meal = mealPlan.meals.firstWhere((m) => m.id == mealId);
    meal.markAsCooked();
    
    await _saveMealPlan(mealPlan);
    
    debugPrint('✅ Marked meal as cooked');
  }

  /// Get meal plan for a specific date
  MealPlan? getMealPlanForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    try {
      return _mealPlans.firstWhere(
        (plan) => _isSameDay(plan.date, normalizedDate),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get meals for a specific date and meal type
  List<PlannedMeal> getMealsForDateTime(DateTime date, MealType mealType) {
    final mealPlan = getMealPlanForDate(date);
    if (mealPlan == null) return [];
    
    return mealPlan.meals.where((meal) => meal.mealType == mealType).toList();
  }

  /// Generate shopping list for a date range
  Future<List<String>> generateShoppingList(DateTime startDate, DateTime endDate) async {
    final ingredients = <String>[];
    
    for (final mealPlan in _mealPlans) {
      if (mealPlan.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          mealPlan.date.isBefore(endDate.add(const Duration(days: 1)))) {
        ingredients.addAll(mealPlan.allIngredients);
      }
    }
    
    return ingredients.toSet().toList(); // Remove duplicates
  }

  /// Get AI suggestions for meal planning
  Future<List<Recipe>> getSuggestionsForMealType(MealType mealType, List<Map<String, dynamic>> pantryItems) async {
    final allSuggestions = _suggestionService.getSuggestions(pantryItems);
    
    // Filter by meal type based on tags
    return allSuggestions
        .where((match) => _isRecipeSuitableForMealType(match.recipe, mealType))
        .map((match) => match.recipe)
        .take(10)
        .toList();
  }

  /// Auto-generate meal plan for a week
  Future<void> generateWeeklyMealPlan(DateTime weekStart, List<Map<String, dynamic>> pantryItems) async {
    final suggestions = _suggestionService.getSuggestions(pantryItems);
    if (suggestions.isEmpty) return;

    final recipes = suggestions.map((match) => match.recipe).toList();
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      
      // Skip if already has meal plan
      if (getMealPlanForDate(date) != null) continue;
      
      final mealPlan = await createMealPlan(date);
      
      // Add breakfast (if available)
      final breakfastRecipes = recipes.where((r) => _isRecipeSuitableForMealType(r, MealType.breakfast)).toList();
      if (breakfastRecipes.isNotEmpty) {
        final recipe = breakfastRecipes[i % breakfastRecipes.length];
        await addMealToPlan(date, MealType.breakfast, recipe);
      }
      
      // Add lunch
      final lunchRecipes = recipes.where((r) => _isRecipeSuitableForMealType(r, MealType.lunch)).toList();
      if (lunchRecipes.isNotEmpty) {
        final recipe = lunchRecipes[i % lunchRecipes.length];
        await addMealToPlan(date, MealType.lunch, recipe);
      }
      
      // Add dinner
      final dinnerRecipes = recipes.where((r) => _isRecipeSuitableForMealType(r, MealType.dinner)).toList();
      if (dinnerRecipes.isNotEmpty) {
        final recipe = dinnerRecipes[i % dinnerRecipes.length];
        await addMealToPlan(date, MealType.dinner, recipe);
      }
    }
    
    debugPrint('✅ Generated weekly meal plan');
  }

  /// Navigate to different weeks
  void goToPreviousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    loadMealPlans();
  }

  void goToNextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    loadMealPlans();
  }

  void goToCurrentWeek() {
    _currentWeekStart = DateTime.now();
    loadMealPlans();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final totalPlans = _mealPlans.length;
    final completedPlans = _mealPlans.where((plan) => plan.isCompleted).length;
    final totalMeals = _mealPlans.fold<int>(0, (sum, plan) => sum + plan.meals.length);
    final cookedMeals = _mealPlans.fold<int>(0, (sum, plan) => 
        sum + plan.meals.where((meal) => meal.isCooked).length);

    return {
      'totalPlans': totalPlans,
      'completedPlans': completedPlans,
      'completionRate': totalPlans > 0 ? (completedPlans / totalPlans * 100).round() : 0,
      'totalMeals': totalMeals,
      'cookedMeals': cookedMeals,
      'cookingRate': totalMeals > 0 ? (cookedMeals / totalMeals * 100).round() : 0,
    };
  }

  // Private helper methods
  Future<MealPlan> _getOrCreateMealPlan(DateTime date) async {
    final existing = getMealPlanForDate(date);
    if (existing != null) return existing;
    
    return await createMealPlan(date);
  }

  Future<void> _saveMealPlan(MealPlan mealPlan) async {
    final userId = _auth.userId;
    if (userId == null) return;

    mealPlan.updatedAt = DateTime.now();
    
    await _firestore.db
        .collection('users')
        .doc(userId)
        .collection('meal_plans')
        .doc(mealPlan.id)
        .set(mealPlan.toMap());
    
    notifyListeners();
  }

  String _generateMealPlanId(DateTime date) {
    return 'plan_${date.year}_${date.month}_${date.day}';
  }

  String _generateMealId() {
    return 'meal_${DateTime.now().millisecondsSinceEpoch}';
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return _normalizeDate(date.subtract(Duration(days: weekday - 1)));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isRecipeSuitableForMealType(Recipe recipe, MealType mealType) {
    final tags = recipe.tags?.map((tag) => tag.toLowerCase()) ?? [];
    final title = recipe.title.toLowerCase();
    
    switch (mealType) {
      case MealType.breakfast:
        return tags.contains('breakfast') || 
               title.contains('breakfast') ||
               title.contains('pancake') ||
               title.contains('omelette') ||
               title.contains('toast');
      
      case MealType.lunch:
        return tags.contains('lunch') ||
               title.contains('salad') ||
               title.contains('sandwich') ||
               title.contains('soup') ||
               (recipe.cookTime != null && recipe.cookTime! <= 30);
      
      case MealType.dinner:
        return tags.contains('dinner') ||
               title.contains('pasta') ||
               title.contains('chicken') ||
               title.contains('beef') ||
               (recipe.cookTime != null && recipe.cookTime! > 20);
      
      case MealType.snack:
        return tags.contains('snack') ||
               title.contains('smoothie') ||
               title.contains('fruit') ||
               (recipe.cookTime != null && recipe.cookTime! <= 15);
    }
  }

  void _sortMealPlans() {
    _mealPlans.sort((a, b) => a.date.compareTo(b.date));
  }
}