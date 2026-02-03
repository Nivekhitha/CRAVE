import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class MealPlanService extends ChangeNotifier {
  static const String _boxName = 'meal_plans_v1';
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Box? _box;
  bool _isInitialized = false;

  // Local state: Date -> List of Meal IDs or simple Objects
  // For simplicity, we store JSON map per day
  // Key: "2025-05-20", Value: { 'breakfast': 'Oatmeal', 'lunch': 'Salad'... }
  Map<String, Map<String, dynamic>> _plans = {};
  
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      _loadLocalPlans();
    } catch (e) {
      debugPrint("❌ MealPlanService Error: $e");
    }
  }

  void _loadLocalPlans() {
    if (_box == null) return;
    final allKeys = _box!.keys.cast<String>();
    for (var key in allKeys) {
       final val = _box!.get(key);
       if (val is Map) {
          _plans[key] = Map<String, dynamic>.from(val);
       }
    }
    notifyListeners();
  }

  Map<String, dynamic> getPlanForDate(DateTime date) {
    final key = _dateKey(date);
    return _plans[key] ?? {};
  }

  Future<void> savePlan(DateTime date, String slot, String mealName) async {
    if (!_isInitialized) await init();
    final key = _dateKey(date);
    
    final current = _plans[key] ?? {};
    current[slot] = mealName;
    _plans[key] = current;
    
    await _box?.put(key, current);
    notifyListeners();
    
    // Sync logic would go here
  }

  String _dateKey(DateTime d) => "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
}
