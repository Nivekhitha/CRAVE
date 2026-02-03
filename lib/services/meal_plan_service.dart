import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_plan.dart';
import 'auth_service.dart';

class MealPlanService extends ChangeNotifier {
  static const String _boxName = 'meal_plans_v1';
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Box? _box;
  bool _isInitialized = false;

  // Cache of current week's meal plans
  List<MealPlan> _weekPlans = [];
  List<MealPlan> get weekPlans => _weekPlans;

  // Current week date range
  DateTime? _currentWeekStart;
  DateTime? get currentWeekStart => _currentWeekStart;

  /// Initialize Hive box and load current week
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      await loadCurrentWeek();
      
      // Trigger background sync if user is logged in
      if (_auth.userId != null) {
        syncPendingPlans();
      }
    } catch (e) {
      debugPrint("❌ MealPlanService Init Error: $e");
    }
  }

  /// Load current week's meal plans
  Future<void> loadCurrentWeek() async {
    if (!_isInitialized) await init();
    
    final now = DateTime.now();
    _currentWeekStart = _getWeekStart(now);
    final weekEnd = _currentWeekStart!.add(const Duration(days: 7));
    
    _weekPlans = await _getPlansForDateRange(_currentWeekStart!, weekEnd);
    notifyListeners();
  }

  /// Get meal plan for specific date
  MealPlan? getPlanForDate(DateTime date) {
    final dateKey = _dateKey(date);
    return _weekPlans.firstWhere(
      (plan) => _dateKey(plan.date) == dateKey,
      orElse: () => MealPlan(
        id: 'plan_$dateKey',
        date: date,
        meals: [],
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Add or update a meal in a plan
  Future<void> addMealToPlan(DateTime date, PlannedMeal meal) async {
    if (!_isInitialized) await init();
    
    final dateKey = _dateKey(date);
    MealPlan? existingPlan = _weekPlans.firstWhere(
      (plan) => _dateKey(plan.date) == dateKey,
      orElse: () => MealPlan(
        id: 'plan_$dateKey',
        date: date,
        meals: [],
        createdAt: DateTime.now(),
      ),
    );
    
    // Remove existing meal of same type
    existingPlan.meals.removeWhere((m) => m.mealType == meal.mealType);
    existingPlan.meals.add(meal);
    existingPlan.updatedAt = DateTime.now();
    
    // Save to Hive (mark as unsynced)
    final planData = existingPlan.toMap();
    planData['isSynced'] = false;
    await _box?.put(existingPlan.id, planData);
    
    // Update local cache
    final index = _weekPlans.indexWhere((p) => p.id == existingPlan.id);
    if (index != -1) {
      _weekPlans[index] = existingPlan;
    } else {
      _weekPlans.add(existingPlan);
    }
    
    notifyListeners();
    
    // Background sync
    _syncPlanToFirestore(existingPlan);
  }

  /// Remove meal from plan
  Future<void> removeMealFromPlan(DateTime date, MealType mealType) async {
    if (!_isInitialized) await init();
    
    final dateKey = _dateKey(date);
    final planIndex = _weekPlans.indexWhere((plan) => _dateKey(plan.date) == dateKey);
    
    if (planIndex != -1) {
      final plan = _weekPlans[planIndex];
      plan.meals.removeWhere((meal) => meal.mealType == mealType);
      plan.updatedAt = DateTime.now();
      
      // Save to Hive
      final planData = plan.toMap();
      planData['isSynced'] = false;
      await _box?.put(plan.id, planData);
      
      notifyListeners();
      
      // Background sync
      _syncPlanToFirestore(plan);
    }
  }

  /// Generate shopping list from current week's plans
  List<String> generateShoppingList() {
    final allIngredients = <String>[];
    
    for (final plan in _weekPlans) {
      for (final meal in plan.meals) {
        if (meal.recipe != null) {
          allIngredients.addAll(meal.recipe!.ingredients);
        }
      }
    }
    
    // Remove duplicates and return
    return allIngredients.toSet().toList();
  }

  /// Auto-generate meal plan for the week using AI suggestions
  Future<void> generateWeeklyPlan({
    List<String>? dietaryRestrictions,
    int? targetCalories,
    List<String>? preferredCuisines,
  }) async {
    if (!_isInitialized) await init();
    
    // This would integrate with AI service to generate smart meal plans
    // For now, we'll create a basic structure
    
    final weekStart = _currentWeekStart ?? _getWeekStart(DateTime.now());
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = _dateKey(date);
      
      // Create basic meal structure (would be AI-generated in production)
      final plan = MealPlan(
        id: 'plan_$dateKey',
        date: date,
        meals: [
          PlannedMeal(
            id: 'breakfast_$dateKey',
            mealType: MealType.breakfast,
            customMealName: 'Healthy Breakfast',
          ),
          PlannedMeal(
            id: 'lunch_$dateKey',
            mealType: MealType.lunch,
            customMealName: 'Nutritious Lunch',
          ),
          PlannedMeal(
            id: 'dinner_$dateKey',
            mealType: MealType.dinner,
            customMealName: 'Balanced Dinner',
          ),
        ],
        createdAt: DateTime.now(),
      );
      
      // Save to Hive
      final planData = plan.toMap();
      planData['isSynced'] = false;
      await _box?.put(plan.id, planData);
      
      // Update local cache
      final existingIndex = _weekPlans.indexWhere((p) => p.id == plan.id);
      if (existingIndex != -1) {
        _weekPlans[existingIndex] = plan;
      } else {
        _weekPlans.add(plan);
      }
      
      // Background sync
      _syncPlanToFirestore(plan);
    }
    
    notifyListeners();
  }

  /// Get plans for date range from Hive
  Future<List<MealPlan>> _getPlansForDateRange(DateTime start, DateTime end) async {
    if (_box == null) return [];
    
    final plans = <MealPlan>[];
    final allMaps = _box!.values.cast<Map<dynamic, dynamic>>();
    
    for (final map in allMaps) {
      try {
        // Convert timestamp back to DateTime for comparison
        final planDate = DateTime.fromMillisecondsSinceEpoch(
          map['date'] is Timestamp 
            ? (map['date'] as Timestamp).millisecondsSinceEpoch
            : map['date'] as int
        );
        
        if (planDate.isAfter(start.subtract(const Duration(days: 1))) && 
            planDate.isBefore(end)) {
          final plan = _mealPlanFromMap(Map<String, dynamic>.from(map));
          plans.add(plan);
        }
      } catch (e) {
        debugPrint('❌ Error parsing meal plan: $e');
      }
    }
    
    return plans..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Convert map to MealPlan (handles both Hive and Firestore formats)
  MealPlan _mealPlanFromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'] ?? '',
      date: map['date'] is Timestamp 
        ? (map['date'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      meals: (map['meals'] as List<dynamic>? ?? [])
          .map((mealMap) => PlannedMeal.fromMap(Map<String, dynamic>.from(mealMap)))
          .toList(),
      createdAt: map['createdAt'] is Timestamp 
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null
        ? (map['updatedAt'] is Timestamp 
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int))
        : null,
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
      shoppingList: map['shoppingList'] != null 
        ? List<String>.from(map['shoppingList'])
        : null,
    );
  }

  /// Sync all pending plans
  Future<void> syncPendingPlans() async {
    if (_box == null || _auth.userId == null) return;

    final allMaps = _box!.values.cast<Map<dynamic, dynamic>>();
    final pending = allMaps
        .where((map) => map['isSynced'] != true)
        .map((map) => _mealPlanFromMap(Map<String, dynamic>.from(map)))
        .toList();

    if (pending.isEmpty) return;

    debugPrint("🔄 Syncing ${pending.length} pending meal plans...");
    
    for (var plan in pending) {
      await _syncPlanToFirestore(plan);
    }
  }

  /// Sync a single plan to Firestore
  Future<void> _syncPlanToFirestore(MealPlan plan) async {
    final userId = _auth.userId;
    if (userId == null) return;

    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('mealPlans')
          .doc(plan.id)
          .set(plan.toMap(), SetOptions(merge: true));

      // Mark as synced in Hive
      final planData = plan.toMap();
      planData['isSynced'] = true;
      await _box?.put(plan.id, planData);
      
      debugPrint("✅ Synced meal plan: ${_dateKey(plan.date)}");
    } catch (e) {
      debugPrint("⚠️ Sync failed for plan ${plan.id}: $e");
    }
  }

  /// Helper methods
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _dateKey(DateTime date) => 
    "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

  /// Get nutrition summary for a date
  Map<String, int> getNutritionForDate(DateTime date) {
    final plan = getPlanForDate(date);
    if (plan == null) return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0};
    
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFats = 0;
    
    for (final meal in plan.meals) {
      if (meal.recipe != null) {
        totalCalories += (meal.recipe!.calories ?? 0).toInt();
        totalProtein += (meal.recipe!.protein ?? 0).toInt();
        totalCarbs += (meal.recipe!.carbs ?? 0).toInt();
        totalFats += (meal.recipe!.fats ?? 0).toInt();
      }
    }
    
    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  /// Mark plan as completed
  Future<void> markPlanAsCompleted(DateTime date) async {
    final plan = getPlanForDate(date);
    if (plan != null) {
      plan.isCompleted = true;
      plan.updatedAt = DateTime.now();
      
      final planData = plan.toMap();
      planData['isSynced'] = false;
      await _box?.put(plan.id, planData);
      
      notifyListeners();
      _syncPlanToFirestore(plan);
    }
  }
}
