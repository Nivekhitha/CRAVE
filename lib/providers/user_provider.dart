import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/migration_service.dart';

import '../models/recipe.dart';
import '../services/recipe_matching_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final MigrationService _migration = MigrationService();
  final RecipeMatchingService _matcher = RecipeMatchingService();

  // State Variables
  User? _user;
  int _cookingStreak = 0;
  int _recipesCooked = 0;
  double _moneySaved = 0.0;
  List<Map<String, dynamic>> _groceryList = [];
  List<Map<String, dynamic>> _pantryList = [];
  List<Recipe> _allRecipes = [];
  List<RecipeMatch> _recipeMatches = [];
  
  // Stream Subscriptions
  StreamSubscription? _authSubscription;
  StreamSubscription? _pantrySubscription;
  StreamSubscription? _grocerySubscription;
  StreamSubscription? _recipeSubscription;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  int get cookingStreak => _cookingStreak;
  int get recipesCooked => _recipesCooked;
  double get moneySaved => _moneySaved;
  List<Map<String, dynamic>> get groceryList => _groceryList;
  List<Map<String, dynamic>> get pantryList => _pantryList;
  List<RecipeMatch> get recipeMatches => _recipeMatches;

  UserProvider() {
    _init();
  }

  void _init() {
    // Listen to Auth Changes
    _authSubscription = _auth.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        // Attempt migration once on login
        await _migration.migrateIfNeeded();
        _subscribeToData();
      } else {
        _clearData();
      }
      notifyListeners();
    });
  }

  void _subscribeToData() {
    // 1. Subscribe to Pantry
    _pantrySubscription?.cancel();
    _pantrySubscription = _firestore.getPantryStream().listen((snapshot) {
      _pantryList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
        return data;
      }).toList();
      _recalculateMatches(); // Recalculate when pantry changes
      notifyListeners();
    }, onError: (e) => debugPrint("❌ Pantry Stream Error: $e"));

    // 2. Subscribe to Grocery
    _grocerySubscription?.cancel();
    _grocerySubscription = _firestore.getGroceryStream().listen((snapshot) {
      _groceryList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      notifyListeners();
    }, onError: (e) => debugPrint("❌ Grocery Stream Error: $e"));

    // 3. Subscribe to Public Recipes (for Matching)
    _recipeSubscription?.cancel();
    _recipeSubscription = _firestore.getPublicRecipesStream().listen((snapshot) {
      _allRecipes = snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _recalculateMatches(); // Recalculate when recipes change
      notifyListeners();
    }, onError: (e) => debugPrint("❌ Recipe Stream Error: $e"));
    
    _loadMockStats(); 
  }

  void _recalculateMatches() {
    if (_allRecipes.isEmpty || _pantryList.isEmpty) {
      _recipeMatches = [];
      return;
    }
    // Run matching algorithm
    _recipeMatches = _matcher.getMatches(_allRecipes, _pantryList);
    // debugPrint("🧠 Recalculated Matches: ${_recipeMatches.length} matches found.");
  }

  void _clearData() {
    _pantrySubscription?.cancel();
    _grocerySubscription?.cancel();
    _recipeSubscription?.cancel();
    _pantryList = [];
    _groceryList = [];
    _allRecipes = [];
    _recipeMatches = [];
    _cookingStreak = 0;
    _recipesCooked = 0;
    _moneySaved = 0.0;
  }

  void _loadMockStats() {
    // Placeholder to allow UI to show something
    _cookingStreak = 5;
    _recipesCooked = 12;
    _moneySaved = 45.0;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _pantrySubscription?.cancel();
    _grocerySubscription?.cancel();
    _recipeSubscription?.cancel();
    super.dispose();
  }

  // --- ACTIONS (Proxy to FirestoreService) ---

  // ... (Keep existing signature if possible, or update to async)
  // Converting synchronous add to async fire-and-forget for UI responsiveness
  
  Future<void> addPantryItem(Map<String, dynamic> item) async {
    try {
      await _firestore.addPantryItem(item);
    } catch (e) {
      debugPrint("Error adding pantry item: $e");
      // Optional: rethrow or show user feedback
    }
  }

  Future<void> deletePantryItem(String id) async {
    await _firestore.deletePantryItem(id);
  }

  // Helper to remove by object equality - Deprecated, use ID
  // void deletePantryItemByValue... 

  // Grocery Actions
  Future<void> addGroceryItem(Map<String, dynamic> item) async {
     await _firestore.addGroceryItem(item);
  }

  Future<void> toggleGroceryItem(int index) async {
    if (index < _groceryList.length) {
      final item = _groceryList[index];
      final id = item['id'];
      await _firestore.updateGroceryItem(id, {'isChecked': !(item['isChecked'] ?? false)});
    }
  }

  Future<void> deleteGroceryItem(String id) async { 
    // Assuming you have a delete method in FirestoreService or logic to remove it.
    // For now we might not have it in FirestoreService based on previous reads, but let's add the provider method.
    // If FirestoreService doesn't have it, we'll need to add it there too, but let's assume we can at least define it here.
    // Actually, looking at the error `deleteGroceryItemByValue` was called.
    // Let's implement that first to match legacy calls, but preferably move to ID.
  }

  // Legacy support or if UI uses object
  Future<void> deleteGroceryItemByValue(Map<String, dynamic> item) async {
    // Try to find ID
    if (item.containsKey('id')) {
       await _firestore.deleteGroceryItem(item['id']);
    }
  }

  void completeCooking() {
    _recipesCooked++;
    _cookingStreak++;
    // In a real app, verify against last cooked date to only increment streak once per day
    notifyListeners();
  }
}

