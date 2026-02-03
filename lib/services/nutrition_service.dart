import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'journal_service.dart';
import 'meal_plan_service.dart';
import '../models/nutrition_snapshot.dart';
import '../models/recipe.dart';

class NutritionService extends ChangeNotifier {
  static const String _boxName = 'nutrition_v2';
  static const String _snapshotBoxName = 'nutrition_snapshots_v1';
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final JournalService _journalService;
  final MealPlanService _mealPlanService;
  
  Box? _box;
  Box<NutritionSnapshot>? _snapshotBox;
  bool _isInitialized = false;

  // Enhanced daily nutrition goals with micronutrients
  Map<String, double> _dailyGoals = {
    // Macronutrients
    'calories': 2000.0,
    'protein': 150.0,
    'carbs': 250.0,
    'fats': 65.0,
    'fiber': 25.0,
    'sugar': 50.0,
    'sodium': 2300.0,
    
    // Vitamins (daily values)
    'vitaminA': 900.0, // mcg
    'vitaminC': 90.0,  // mg
    'vitaminD': 20.0,  // mcg
    'vitaminE': 15.0,  // mg
    'vitaminK': 120.0, // mcg
    'vitaminB12': 2.4, // mcg
    'folate': 400.0,   // mcg
    
    // Minerals
    'iron': 18.0,      // mg
    'calcium': 1000.0, // mg
    'zinc': 11.0,      // mg
    'magnesium': 400.0, // mg
    'potassium': 3500.0, // mg
    
    // Hydration
    'water': 8.0, // glasses
  };

  // Current nutrition snapshot
  NutritionSnapshot? _todaySnapshot;
  
  // Weekly snapshots cache
  Map<String, NutritionSnapshot> _weeklySnapshots = {};

  NutritionService(this._journalService, this._mealPlanService);

  // Getters
  Map<String, double> get dailyGoals => _dailyGoals;
  NutritionSnapshot? get todaySnapshot => _todaySnapshot;
  Map<String, NutritionSnapshot> get weeklySnapshots => _weeklySnapshots;

  /// Initialize nutrition service with enhanced features
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _box = await Hive.openBox(_boxName);
      _snapshotBox = await Hive.openBox<NutritionSnapshot>(_snapshotBoxName);
      _isInitialized = true;
      
      await _loadUserGoals();
      await _loadTodaySnapshot();
      await _loadWeeklySnapshots();
      
      debugPrint("✅ Enhanced NutritionService initialized");
    } catch (e) {
      debugPrint("❌ NutritionService Init Error: $e");
    }
  }

  /// Load user's custom nutrition goals
  Future<void> _loadUserGoals() async {
    try {
      final savedGoals = _box?.get('dailyGoals');
      if (savedGoals != null && savedGoals is Map) {
        _dailyGoals = Map<String, double>.from(savedGoals);
      }
    } catch (e) {
      debugPrint("❌ Error loading nutrition goals: $e");
    }
  }

  /// Load today's nutrition snapshot
  Future<void> _loadTodaySnapshot() async {
    final today = _dateKey(DateTime.now());
    
    // Try to load from Hive cache first
    _todaySnapshot = _snapshotBox?.get(today);
    
    if (_todaySnapshot == null) {
      // Generate new snapshot for today
      await _generateTodaySnapshot();
    }
  }

  /// Load weekly nutrition snapshots
  Future<void> _loadWeeklySnapshots() async {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = _dateKey(date);
      
      // Try to load from cache
      final snapshot = _snapshotBox?.get(dateKey);
      if (snapshot != null) {
        _weeklySnapshots[dateKey] = snapshot;
      } else {
        // Generate snapshot for this date
        final newSnapshot = await _generateSnapshotForDate(date);
        _weeklySnapshots[dateKey] = newSnapshot;
        await _snapshotBox?.put(dateKey, newSnapshot);
      }
    }
    
    notifyListeners();
  }

  /// Generate comprehensive nutrition snapshot for a specific date
  Future<NutritionSnapshot> _generateSnapshotForDate(DateTime date) async {
    // Get journal entries for the date
    final entries = await _journalService.getEntriesForDate(date);
    
    // Initialize nutrition totals
    final macros = <String, double>{
      'calories': 0.0,
      'protein': 0.0,
      'carbs': 0.0,
      'fats': 0.0,
      'fiber': 0.0,
      'sugar': 0.0,
      'sodium': 0.0,
    };
    
    final vitamins = <String, double>{
      'vitaminA': 0.0,
      'vitaminC': 0.0,
      'vitaminD': 0.0,
      'vitaminE': 0.0,
      'vitaminK': 0.0,
      'vitaminB12': 0.0,
      'folate': 0.0,
    };
    
    final minerals = <String, double>{
      'iron': 0.0,
      'calcium': 0.0,
      'zinc': 0.0,
      'magnesium': 0.0,
      'potassium': 0.0,
    };
    
    double totalGlycemicIndex = 0.0;
    int glycemicCount = 0;
    
    // Aggregate nutrition from all entries
    for (final entry in entries) {
      macros['calories'] = (macros['calories'] ?? 0) + entry.calories;
      macros['protein'] = (macros['protein'] ?? 0) + entry.protein;
      macros['carbs'] = (macros['carbs'] ?? 0) + entry.carbs;
      macros['fats'] = (macros['fats'] ?? 0) + entry.fats;
      
      // For now, we'll use basic nutrition from journal entries
      // In production, you'd fetch the full recipe data using entry.recipeId
      // and aggregate the detailed nutrition information
      
      // Estimate fiber, sugar, sodium based on macros (simplified)
      macros['fiber'] = (macros['fiber'] ?? 0) + (entry.carbs * 0.1); // Rough estimate
      macros['sugar'] = (macros['sugar'] ?? 0) + (entry.carbs * 0.3); // Rough estimate
      macros['sodium'] = (macros['sodium'] ?? 0) + (entry.calories * 0.5); // Rough estimate
      
      // Estimate vitamins and minerals (simplified for demo)
      vitamins['vitaminC'] = (vitamins['vitaminC'] ?? 0) + (entry.calories * 0.02);
      vitamins['vitaminA'] = (vitamins['vitaminA'] ?? 0) + (entry.calories * 0.01);
      minerals['iron'] = (minerals['iron'] ?? 0) + (entry.protein * 0.1);
      minerals['calcium'] = (minerals['calcium'] ?? 0) + (entry.protein * 0.2);
      
      // TODO: In production, fetch actual recipe data:
      // if (entry.recipeId != null) {
      //   final recipe = await _getRecipeById(entry.recipeId!);
      //   if (recipe != null) {
      //     // Add detailed nutrition from recipe
      //   }
      // }
    }
    
    // Get water intake
    final waterGlasses = _box?.get('water_${_dateKey(date)}', defaultValue: 0) ?? 0;
    
    // Calculate progress against goals
    final progress = <String, double>{};
    [...macros.keys, ...vitamins.keys, ...minerals.keys, 'water'].forEach((key) {
      final current = key == 'water' ? waterGlasses.toDouble() : 
                     (macros[key] ?? vitamins[key] ?? minerals[key] ?? 0.0);
      final goal = _dailyGoals[key] ?? 1.0;
      progress[key] = (current / goal * 100).clamp(0, 200);
    });
    
    // Calculate nutrition score
    final nutritionScore = NutritionSnapshot.calculateNutritionScore(progress);
    
    // Generate AI insights
    final insights = NutritionSnapshot.generateInsights(progress, macros, waterGlasses);
    
    // Calculate average glycemic index
    final averageGI = glycemicCount > 0 ? totalGlycemicIndex / glycemicCount : 0.0;
    
    return NutritionSnapshot(
      date: date,
      macros: macros,
      vitamins: vitamins,
      minerals: minerals,
      goals: _dailyGoals,
      progress: progress,
      nutritionScore: nutritionScore,
      insights: insights,
      waterGlasses: waterGlasses,
      averageGlycemicIndex: averageGI,
      lastUpdated: DateTime.now(),
    );
  }

  /// Generate today's nutrition snapshot
  Future<void> _generateTodaySnapshot() async {
    final today = DateTime.now();
    _todaySnapshot = await _generateSnapshotForDate(today);
    
    // Cache the snapshot
    final dateKey = _dateKey(today);
    await _snapshotBox?.put(dateKey, _todaySnapshot!);
    
    // Sync to Firestore
    await _syncSnapshotToFirestore(_todaySnapshot!);
    
    notifyListeners();
  }

  /// Sync nutrition snapshot to Firestore
  Future<void> _syncSnapshotToFirestore(NutritionSnapshot snapshot) async {
    final userId = _auth.userId;
    if (userId == null) return;
    
    try {
      final dateKey = _dateKey(snapshot.date);
      await _db
          .collection('users')
          .doc(userId)
          .collection('nutrition_snapshots')
          .doc(dateKey)
          .set(snapshot.toMap());
    } catch (e) {
      debugPrint("❌ Failed to sync nutrition snapshot: $e");
    }
  }

  /// Get today's nutrition data (backward compatibility)
  Map<String, int> getTodayNutrition() {
    if (_todaySnapshot == null) return {};
    
    return {
      'calories': _todaySnapshot!.macros['calories']?.toInt() ?? 0,
      'protein': _todaySnapshot!.macros['protein']?.toInt() ?? 0,
      'carbs': _todaySnapshot!.macros['carbs']?.toInt() ?? 0,
      'fats': _todaySnapshot!.macros['fats']?.toInt() ?? 0,
      'fiber': _todaySnapshot!.macros['fiber']?.toInt() ?? 0,
      'sugar': _todaySnapshot!.macros['sugar']?.toInt() ?? 0,
      'sodium': _todaySnapshot!.macros['sodium']?.toInt() ?? 0,
      'water': _todaySnapshot!.waterGlasses,
    };
  }

  /// Get nutrition progress for today (percentage of goals)
  Map<String, double> getTodayProgress() {
    return _todaySnapshot?.progress ?? {};
  }

  /// Get today's nutrition score
  int getNutritionScore() {
    return _todaySnapshot?.nutritionScore ?? 0;
  }

  /// Get today's AI insights
  List<String> getTodayInsights() {
    return _todaySnapshot?.insights ?? [];
  }

  /// Get macro distribution for today
  Map<String, double> getMacroDistribution() {
    if (_todaySnapshot == null) return {'protein': 0, 'carbs': 0, 'fats': 0};
    
    final macros = _todaySnapshot!.macros;
    final protein = (macros['protein'] ?? 0) * 4; // 4 cal per gram
    final carbs = (macros['carbs'] ?? 0) * 4; // 4 cal per gram
    final fats = (macros['fats'] ?? 0) * 9; // 9 cal per gram
    
    final total = protein + carbs + fats;
    if (total == 0) return {'protein': 0, 'carbs': 0, 'fats': 0};
    
    return {
      'protein': protein / total * 100,
      'carbs': carbs / total * 100,
      'fats': fats / total * 100,
    };
  }

  /// Update daily nutrition goals with enhanced validation
  Future<void> updateDailyGoals(Map<String, double> newGoals) async {
    if (!_isInitialized) await init();
    
    // Validate goals
    final validatedGoals = <String, double>{};
    newGoals.forEach((key, value) {
      if (value > 0 && _dailyGoals.containsKey(key)) {
        validatedGoals[key] = value;
      }
    });
    
    _dailyGoals = {..._dailyGoals, ...validatedGoals};
    await _box?.put('dailyGoals', _dailyGoals);
    
    // Regenerate today's snapshot with new goals
    await _generateTodaySnapshot();
    
    // Sync to Firestore
    final userId = _auth.userId;
    if (userId != null) {
      _db.collection('users').doc(userId).set({
        'nutritionGoals': _dailyGoals,
        'goalsUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((e) {
        debugPrint("❌ Failed to sync nutrition goals: $e");
      });
    }
    
    notifyListeners();
  }

  /// Log water intake with real-time updates
  Future<void> logWater(int glasses) async {
    if (!_isInitialized) await init();
    
    final today = _dateKey(DateTime.now());
    
    // Update water intake
    await _box?.put('water_$today', glasses);
    
    // Update today's snapshot
    if (_todaySnapshot != null) {
      _todaySnapshot!.waterGlasses = glasses;
      
      // Recalculate progress
      final progress = Map<String, double>.from(_todaySnapshot!.progress);
      progress['water'] = (glasses / (_dailyGoals['water'] ?? 8) * 100).clamp(0, 200);
      _todaySnapshot!.progress = progress;
      
      // Recalculate score and insights
      _todaySnapshot!.nutritionScore = NutritionSnapshot.calculateNutritionScore(progress);
      _todaySnapshot!.insights = NutritionSnapshot.generateInsights(
        progress, 
        _todaySnapshot!.macros, 
        glasses
      );
      
      // Cache updated snapshot
      await _snapshotBox?.put(today, _todaySnapshot!);
      await _syncSnapshotToFirestore(_todaySnapshot!);
    }
    
    notifyListeners();
  }

  /// Get weekly nutrition trends for charts
  Map<String, List<double>> getWeeklyTrends() {
    final trends = <String, List<double>>{};
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    
    for (final nutrient in ['calories', 'protein', 'carbs', 'fats', 'fiber']) {
      final values = <double>[];
      
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateKey = _dateKey(date);
        final snapshot = _weeklySnapshots[dateKey];
        values.add(snapshot?.macros[nutrient] ?? 0.0);
      }
      
      trends[nutrient] = values;
    }
    
    return trends;
  }

  /// Get vitamin and mineral status
  Map<String, Map<String, double>> getMicronutrientStatus() {
    if (_todaySnapshot == null) return {'vitamins': {}, 'minerals': {}};
    
    return {
      'vitamins': _todaySnapshot!.vitamins,
      'minerals': _todaySnapshot!.minerals,
    };
  }

  /// Refresh all nutrition data
  Future<void> refreshNutritionData() async {
    if (!_isInitialized) await init();
    
    // Regenerate today's snapshot
    await _generateTodaySnapshot();
    
    // Regenerate weekly snapshots
    await _loadWeeklySnapshots();
    
    debugPrint("✅ Nutrition data refreshed");
  }

  /// Get recommended daily goals based on user profile (enhanced)
  Map<String, double> getRecommendedGoals({
    required int age,
    required String gender,
    required double weight, // kg
    required double height, // cm
    required String activityLevel,
    String? healthGoal, // weight_loss, muscle_gain, maintenance
    List<String>? dietaryRestrictions,
  }) {
    // Basic BMR calculation (Mifflin-St Jeor Equation)
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }
    
    // Activity multiplier
    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.375;
    }
    
    double calories = bmr * activityMultiplier;
    
    // Adjust for health goals
    switch (healthGoal?.toLowerCase()) {
      case 'weight_loss':
        calories *= 0.85; // 15% deficit
        break;
      case 'muscle_gain':
        calories *= 1.15; // 15% surplus
        break;
      default:
        // maintenance - no change
        break;
    }
    
    // Calculate macronutrients
    final protein = weight * (healthGoal == 'muscle_gain' ? 2.2 : 1.6); // g per kg
    final fats = calories * 0.25 / 9; // 25% of calories from fats
    final carbs = (calories - (protein * 4) - (fats * 9)) / 4; // remaining calories
    
    return {
      // Macronutrients
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': 25.0 + (age > 50 ? 5.0 : 0.0), // Higher for older adults
      'sugar': calories * 0.1 / 4, // 10% of calories
      'sodium': gender.toLowerCase() == 'male' ? 2300.0 : 2000.0,
      
      // Vitamins (adjusted for age/gender)
      'vitaminA': gender.toLowerCase() == 'male' ? 900.0 : 700.0,
      'vitaminC': gender.toLowerCase() == 'male' ? 90.0 : 75.0,
      'vitaminD': age > 70 ? 20.0 : 15.0,
      'vitaminE': 15.0,
      'vitaminK': gender.toLowerCase() == 'male' ? 120.0 : 90.0,
      'vitaminB12': 2.4,
      'folate': 400.0,
      
      // Minerals (adjusted for age/gender)
      'iron': gender.toLowerCase() == 'male' ? 8.0 : (age > 50 ? 8.0 : 18.0),
      'calcium': age > 50 ? 1200.0 : 1000.0,
      'zinc': gender.toLowerCase() == 'male' ? 11.0 : 8.0,
      'magnesium': gender.toLowerCase() == 'male' ? 400.0 : 310.0,
      'potassium': 3500.0,
      
      // Hydration (adjusted for activity and weight)
      'water': (weight * 0.033 + (activityMultiplier > 1.5 ? 2 : 0)).clamp(6, 12),
    };
  }

  /// Export nutrition data as comprehensive report
  Future<Map<String, dynamic>> exportNutritionReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    startDate ??= DateTime.now().subtract(const Duration(days: 30));
    endDate ??= DateTime.now();
    
    final snapshots = <NutritionSnapshot>[];
    
    // Collect snapshots for date range
    for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); 
         date = date.add(const Duration(days: 1))) {
      final dateKey = _dateKey(date);
      final snapshot = _snapshotBox?.get(dateKey);
      if (snapshot != null) {
        snapshots.add(snapshot);
      }
    }
    
    // Calculate averages and trends
    final avgScore = snapshots.isEmpty ? 0 : 
      snapshots.map((s) => s.nutritionScore).reduce((a, b) => a + b) / snapshots.length;
    
    final avgCalories = snapshots.isEmpty ? 0 : 
      snapshots.map((s) => s.macros['calories'] ?? 0).reduce((a, b) => a + b) / snapshots.length;
    
    return {
      'period': {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalDays': snapshots.length,
      },
      'averages': {
        'nutritionScore': avgScore.round(),
        'calories': avgCalories.round(),
        'protein': snapshots.isEmpty ? 0 : 
          snapshots.map((s) => s.macros['protein'] ?? 0).reduce((a, b) => a + b) / snapshots.length,
        'hydration': snapshots.isEmpty ? 0 : 
          snapshots.map((s) => s.waterGlasses).reduce((a, b) => a + b) / snapshots.length,
      },
      'goals': _dailyGoals,
      'snapshots': snapshots.map((s) => s.toMap()).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Helper methods
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _dateKey(DateTime date) => 
    "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
}