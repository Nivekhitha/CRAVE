import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProvider extends ChangeNotifier {
  // final Box _box = Hive.box('user_data');

  // State Variables
  late int _cookingStreak;
  late int _recipesCooked;
  late double _moneySaved;
  late List<Map<String, dynamic>> _groceryList;
  late List<Map<String, dynamic>> _pantryList;
  
  // Getters
  int get cookingStreak => _cookingStreak;
  int get recipesCooked => _recipesCooked;
  double get moneySaved => _moneySaved;
  List<Map<String, dynamic>> get groceryList => _groceryList;
  List<Map<String, dynamic>> get pantryList => _pantryList;

  UserProvider() {
    _loadData();
  }

  void _loadData() {
    // _cookingStreak = _box.get('cookingStreak', defaultValue: 5);
    // _recipesCooked = _box.get('recipesCooked', defaultValue: 12);
    // _moneySaved = _box.get('moneySaved', defaultValue: 45.0);
    
    // Mock Data for Debugging
    _cookingStreak = 5;
    _recipesCooked = 12;
    _moneySaved = 45.0;

    _groceryList = [];
    _pantryList = [];
    
    // Hive stores Lists as dynamic, need enabling casting
    // final groceryRaw = _box.get('groceryList', defaultValue: []);
    // _groceryList = List<Map<String, dynamic>>.from(
    //   groceryRaw.map((item) => Map<String, dynamic>.from(item))
    // );

    // final pantryRaw = _box.get('pantryList', defaultValue: []);
    // _pantryList = List<Map<String, dynamic>>.from(
    //   pantryRaw.map((item) => Map<String, dynamic>.from(item))
    // );
  }

  // --- STATS ACTIONS ---
  void completeCooking() {
    _cookingStreak++;
    _recipesCooked++;
    _moneySaved += 5.0; 
    _saveStats();
    notifyListeners();
  }

  void _saveStats() {
    // _box.put('cookingStreak', _cookingStreak);
    // _box.put('recipesCooked', _recipesCooked);
    // _box.put('moneySaved', _moneySaved);
  }

  // --- GROCERY ACTIONS ---
  void addGroceryItem(Map<String, dynamic> item) {
    _groceryList.add(item);
    _saveGrocery();
    notifyListeners();
  }
  
  void toggleGroceryItem(int index) {
    _groceryList[index]['checked'] = !(_groceryList[index]['checked'] ?? false);
    _saveGrocery();
    notifyListeners();
  }

  void deleteGroceryItem(int index) {
    _groceryList.removeAt(index);
    _saveGrocery();
    notifyListeners();
  }
  
  // Helper to remove by object equality if needed, but index is safer for UI
  void deleteGroceryItemByValue(Map<String, dynamic> item) {
     _groceryList.removeWhere((i) => i['name'] == item['name'] && i['category'] == item['category']);
     _saveGrocery();
     notifyListeners();
  }

  void _saveGrocery() {
    // _box.put('groceryList', _groceryList);
  }

  // --- PANTRY ACTIONS ---
  void addPantryItem(Map<String, dynamic> item) {
    _pantryList.add(item);
    _savePantry();
    notifyListeners();
  }

  void updatePantryItem(int index, Map<String, dynamic> item) {
    _pantryList[index] = item;
    _savePantry();
    notifyListeners();
  }
  
  void deletePantryItem(int index) {
    _pantryList.removeAt(index);
    _savePantry();
    notifyListeners();
  }

   void deletePantryItemByValue(Map<String, dynamic> item) {
     _pantryList.removeWhere((i) => i['name'] == item['name']);
     _savePantry();
     notifyListeners();
  }

  void _savePantry() {
    // _box.put('pantryList', _pantryList);
  }
}
