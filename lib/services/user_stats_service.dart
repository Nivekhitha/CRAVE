import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Service to track and manage user cooking statistics
class UserStatsService extends ChangeNotifier {
  static const String _hiveBoxName = 'user_stats_v1';
  
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Box? _statsBox;

  // User stats
  int _recipesCooked = 0;
  int _recipesSaved = 0;
  int _mealsLogged = 0;
  int _groceryListsCreated = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastCookingDate;
  DateTime? _joinDate;
  double _averageRating = 0.0;
  List<DateTime> _cookingDates = [];

  // Getters
  int get recipesCooked => _recipesCooked;
  int get recipesSaved => _recipesSaved;
  int get mealsLogged => _mealsLogged;
  int get groceryListsCreated => _groceryListsCreated;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastCookingDate => _lastCookingDate;
  DateTime? get joinDate => _joinDate;
  double get averageRating => _averageRating;
  List<DateTime> get cookingDates => List.unmodifiable(_cookingDates);

  /// Initialize the service
  Future<void> init() async {
    await _initHive();
    await _loadLocalStats();
    _calculateStreak();
    notifyListeners();
  }

  /// Initialize Hive box
  Future<void> _initHive() async {
    try {
      _statsBox = await Hive.openBox(_hiveBoxName);
    } catch (e) {
      debugPrint('❌ Error initializing user stats Hive box: $e');
    }
  }

  /// Load stats from local storage
  Future<void> _loadLocalStats() async {
    try {
      _recipesCooked = _statsBox?.get('recipesCooked', defaultValue: 0) ?? 0;
      _recipesSaved = _statsBox?.get('recipesSaved', defaultValue: 0) ?? 0;
      _mealsLogged = _statsBox?.get('mealsLogged', defaultValue: 0) ?? 0;
      _groceryListsCreated = _statsBox?.get('groceryListsCreated', defaultValue: 0) ?? 0;
      _currentStreak = _statsBox?.get('currentStreak', defaultValue: 0) ?? 0;
      _longestStreak = _statsBox?.get('longestStreak', defaultValue: 0) ?? 0;
      _averageRating = _statsBox?.get('averageRating', defaultValue: 4.8) ?? 4.8;
      
      final lastCookingTimestamp = _statsBox?.get('lastCookingDate');
      if (lastCookingTimestamp != null) {
        _lastCookingDate = DateTime.fromMillisecondsSinceEpoch(lastCookingTimestamp);
      }
      
      final joinTimestamp = _statsBox?.get('joinDate');
      if (joinTimestamp != null) {
        _joinDate = DateTime.fromMillisecondsSinceEpoch(joinTimestamp);
      } else {
        _joinDate = DateTime.now();
        await _saveJoinDate();
      }
      
      final cookingDatesData = _statsBox?.get('cookingDates', defaultValue: <int>[]) ?? <int>[];
      _cookingDates = cookingDatesData.map((timestamp) => DateTime.fromMillisecondsSinceEpoch(timestamp)).toList();
      
      debugPrint('📊 Loaded user stats: $_recipesCooked recipes cooked, $_currentStreak day streak');
    } catch (e) {
      debugPrint('❌ Error loading user stats: $e');
    }
  }

  /// Record a recipe being cooked
  Future<void> recordRecipeCooked() async {
    _recipesCooked++;
    final today = DateTime.now();
    _lastCookingDate = today;
    
    // Add to cooking dates if not already added today
    final todayStart = DateTime(today.year, today.month, today.day);
    if (!_cookingDates.any((date) => 
        date.year == todayStart.year && 
        date.month == todayStart.month && 
        date.day == todayStart.day)) {
      _cookingDates.add(todayStart);
    }
    
    _calculateStreak();
    await _saveStats();
    
    debugPrint('🍳 Recipe cooked! Total: $_recipesCooked, Streak: $_currentStreak');
    notifyListeners();
  }

  /// Record a recipe being saved
  Future<void> recordRecipeSaved() async {
    _recipesSaved++;
    await _saveStats();
    debugPrint('💾 Recipe saved! Total: $_recipesSaved');
    notifyListeners();
  }

  /// Record a meal being logged
  Future<void> recordMealLogged() async {
    _mealsLogged++;
    await _saveStats();
    debugPrint('📝 Meal logged! Total: $_mealsLogged');
    notifyListeners();
  }

  /// Record a grocery list being created
  Future<void> recordGroceryListCreated() async {
    _groceryListsCreated++;
    await _saveStats();
    debugPrint('🛒 Grocery list created! Total: $_groceryListsCreated');
    notifyListeners();
  }

  /// Calculate current cooking streak
  void _calculateStreak() {
    if (_cookingDates.isEmpty) {
      _currentStreak = 0;
      return;
    }

    // Sort dates in descending order
    _cookingDates.sort((a, b) => b.compareTo(a));
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    
    int streak = 0;
    DateTime checkDate = todayStart;
    
    // Check if user cooked today or yesterday (to maintain streak)
    bool foundRecent = _cookingDates.any((date) => 
        _isSameDay(date, todayStart) || _isSameDay(date, yesterdayStart));
    
    if (!foundRecent) {
      _currentStreak = 0;
      return;
    }
    
    // Count consecutive days
    for (int i = 0; i < _cookingDates.length; i++) {
      if (_isSameDay(_cookingDates[i], checkDate) || 
          _isSameDay(_cookingDates[i], checkDate.subtract(const Duration(days: 1)))) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    _currentStreak = streak;
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  /// Save stats to local storage
  Future<void> _saveStats() async {
    try {
      await _statsBox?.put('recipesCooked', _recipesCooked);
      await _statsBox?.put('recipesSaved', _recipesSaved);
      await _statsBox?.put('mealsLogged', _mealsLogged);
      await _statsBox?.put('groceryListsCreated', _groceryListsCreated);
      await _statsBox?.put('currentStreak', _currentStreak);
      await _statsBox?.put('longestStreak', _longestStreak);
      await _statsBox?.put('averageRating', _averageRating);
      
      if (_lastCookingDate != null) {
        await _statsBox?.put('lastCookingDate', _lastCookingDate!.millisecondsSinceEpoch);
      }
      
      final cookingDatesData = _cookingDates.map((date) => date.millisecondsSinceEpoch).toList();
      await _statsBox?.put('cookingDates', cookingDatesData);
      
      // Fire-and-forget Firestore sync
      _syncToFirestore();
    } catch (e) {
      debugPrint('❌ Error saving user stats: $e');
    }
  }

  /// Save join date
  Future<void> _saveJoinDate() async {
    try {
      if (_joinDate != null) {
        await _statsBox?.put('joinDate', _joinDate!.millisecondsSinceEpoch);
      }
    } catch (e) {
      debugPrint('❌ Error saving join date: $e');
    }
  }

  /// Sync stats to Firestore (fire-and-forget)
  void _syncToFirestore() {
    final userId = _auth.userId;
    if (userId == null) return;

    _db.collection('users').doc(userId).set({
      'stats': {
        'recipesCooked': _recipesCooked,
        'recipesSaved': _recipesSaved,
        'mealsLogged': _mealsLogged,
        'groceryListsCreated': _groceryListsCreated,
        'currentStreak': _currentStreak,
        'longestStreak': _longestStreak,
        'averageRating': _averageRating,
        'lastCookingDate': _lastCookingDate?.millisecondsSinceEpoch,
        'joinDate': _joinDate?.millisecondsSinceEpoch,
        'lastUpdated': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true)).catchError((e) {
      debugPrint('❌ Error syncing stats to Firestore: $e');
    });
  }

  /// Get streak emoji based on current streak
  String get streakEmoji {
    if (_currentStreak == 0) return '😴';
    if (_currentStreak < 3) return '🔥';
    if (_currentStreak < 7) return '🚀';
    if (_currentStreak < 14) return '⭐';
    if (_currentStreak < 30) return '🏆';
    return '👑';
  }

  /// Get streak message
  String get streakMessage {
    if (_currentStreak == 0) return 'Start your cooking streak!';
    if (_currentStreak == 1) return 'Great start!';
    if (_currentStreak < 7) return 'Keep it up!';
    if (_currentStreak < 14) return 'You\'re on fire!';
    if (_currentStreak < 30) return 'Cooking master!';
    return 'Legendary chef!';
  }

  /// Get days since joining
  int get daysSinceJoining {
    if (_joinDate == null) return 0;
    return DateTime.now().difference(_joinDate!).inDays;
  }

  /// Reset stats (for testing)
  Future<void> resetStats() async {
    _recipesCooked = 0;
    _recipesSaved = 0;
    _mealsLogged = 0;
    _groceryListsCreated = 0;
    _currentStreak = 0;
    _longestStreak = 0;
    _lastCookingDate = null;
    _cookingDates.clear();
    _averageRating = 4.8;
    
    await _saveStats();
    notifyListeners();
  }
}