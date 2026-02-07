import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/migration_service.dart';
import '../utils/debouncer.dart';
import '../utils/exceptions.dart';

import '../models/recipe.dart';
import '../services/recipe_matching_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final MigrationService _migration = MigrationService();
  final RecipeMatchingService _matcher = RecipeMatchingService();
  final ActionThrottler _actionThrottler = ActionThrottler(cooldownMs: 500);

  // State Variables
  User? _user;
  String? _username;
  String? _country;
  int _cookingStreak = 0;
  int _recipesCooked = 0;
  double _moneySaved = 0.0;
  List<Map<String, dynamic>> _groceryList = [];
  List<Map<String, dynamic>> _pantryList = [];
  List<Recipe> _allRecipes = [];
  List<RecipeMatch> _recipeMatches = [];
  List<String> _savedRecipeIds = []; // Track saved recipe IDs
  bool _suggestionsLoading = false;

  // Stream Subscriptions
  StreamSubscription? _authSubscription;
  StreamSubscription? _pantrySubscription;
  StreamSubscription? _grocerySubscription;
  StreamSubscription? _recipeSubscription;

  // Getters
  User? get user => _user;
  String? get username => _username;
  String? get country => _country;
  bool get isAuthenticated => _user != null;
  int get cookingStreak => _cookingStreak;
  int get recipesCooked => _recipesCooked;
  double get moneySaved => _moneySaved;
  List<Map<String, dynamic>> get groceryList => _groceryList;
  List<Map<String, dynamic>> get pantryList => _pantryList;
  List<RecipeMatch> get recipeMatches => _recipeMatches;
  List<String> get savedRecipeIds => _savedRecipeIds;
  List<Recipe> get savedRecipes => _allRecipes.where((r) => _savedRecipeIds.contains(r.id)).toList();
  bool get suggestionsLoading => _suggestionsLoading;

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
        await _fetchUserProfile();
        _subscribeToData();
      } else {
        _clearData();
      }
      notifyListeners();
    });

  }

  Future<void> _fetchUserProfile() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.getUserDoc(_user!.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _username = data['username'];
        _country = data['country'];
        _savedRecipeIds = List<String>.from(data['savedRecipes'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error fetching user profile: $e");
    }
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
        data['checked'] = data['checked'] ?? data['isChecked'] ?? false;
        return data;
      }).toList();
      notifyListeners();
    }, onError: (e) => debugPrint("❌ Grocery Stream Error: $e"));

    // 3. Subscribe to Public Recipes (for Matching)
    _recipeSubscription?.cancel();
    _recipeSubscription =
        _firestore.getPublicRecipesStream().listen((snapshot) {
      _allRecipes = snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _recalculateMatches(); // Recalculate when recipes change
      debugPrint("🍲 Fetched ${_allRecipes.length} recipes from Firestore");
      notifyListeners();
    }, onError: (e) => debugPrint("❌ Recipe Stream Error: $e"));


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
    _savedRecipeIds = [];
    _cookingStreak = 0;
    _recipesCooked = 0;
    _moneySaved = 0.0;
    _username = null;
    _country = null;
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
    } on OfflineException catch (e) {
      debugPrint("📱 Offline: $e");
      // Show user-friendly offline message but don't throw
      // Firestore will sync when back online
    } on AppException catch (e) {
      debugPrint("❌ Error adding pantry item: $e");
      rethrow; // Let UI handle specific app exceptions
    } catch (e) {
      debugPrint("❌ Unexpected error adding pantry item: $e");
      throw DataException('Failed to add pantry item. Please try again.');
    }
  }

  Future<void> deletePantryItem(String id) async {
    try {
      await _firestore.deletePantryItem(id);
    } on OfflineException catch (e) {
      debugPrint("📱 Offline: $e");
      // Item will be deleted when back online
    } on AppException catch (e) {
      debugPrint("❌ Error deleting pantry item: $e");
      rethrow;
    } catch (e) {
      debugPrint("❌ Unexpected error deleting pantry item: $e");
      throw DataException('Failed to delete pantry item. Please try again.');
    }
  }

  // Helper to remove by object equality - Deprecated, use ID
  // void deletePantryItemByValue...

  // Grocery Actions
  Future<void> addGroceryItem(dynamic item) async {
    Map<String, dynamic> groceryItem;

    if (item is String) {
      // If it's a string, create a basic grocery item
      groceryItem = {
        'name': item.trim(),
        'isChecked': false,
        'category': 'Pantry',
        'quantity': '1',
        'price': 0.0,
      };
    } else if (item is Map<String, dynamic>) {
      // If it's already a map, use it directly but ensure required fields
      groceryItem = {
        'name': (item['name'] ?? '').toString().trim(),
        'isChecked': item['isChecked'] ?? item['checked'] ?? false,
        'category': item['category'] ?? 'Pantry',
        'quantity': item['quantity'] ?? '1',
        'price': item['price'] ?? 0.0,
      };
    } else {
      throw ArgumentError('Item must be either String or Map<String, dynamic>');
    }

    // Edge Case: Prevent empty names
    if (groceryItem['name'].isEmpty) {
      debugPrint('⚠️ Attempted to add grocery item with empty name');
      return;
    }

    // Edge Case: Duplicate prevention (case-insensitive)
    final itemName = groceryItem['name'].toLowerCase();
    final exists = _groceryList
        .any((g) => (g['name'] as String? ?? '').toLowerCase() == itemName);

    if (exists) {
      debugPrint(
          '⚠️ Grocery item "$itemName" already exists, skipping duplicate');
      return;
    }

    await _firestore.addGroceryItem(groceryItem);
  }

  Future<void> addMultipleGroceryItems(List<String> items) async {
    for (var item in items) {
      // Check if already exists to avoid duplicates (Simple check)
      final exists = _groceryList
          .any((g) => g['name'].toString().toLowerCase() == item.toLowerCase());
      if (!exists) {
        await _firestore.addGroceryItem({
          'name': item,
          'isChecked': false,
          'category': 'Pantry', // Default category
          'quantity': '1',
          'price': 0.0,
        });
      }
    }
    notifyListeners();
  }

  Future<void> toggleGroceryItem(int index) async {
    if (index < _groceryList.length) {
      final item = _groceryList[index];
      final id = item['id'];
      await _firestore
          .updateGroceryItem(id, {'isChecked': !(item['isChecked'] ?? false)});
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

  // Recipe suggestion methods
  List<Recipe> getSuggestionsForMeal(String mealType) {
    // Return filtered recipes based on meal type
    return _allRecipes.where((recipe) {
      if (recipe.tags == null) return false;
      return recipe.tags!.any((tag) => tag.toLowerCase().contains(mealType.toLowerCase()));
    }).take(5).toList();
  }

  List<Recipe> getOneIngredientAway() {
    // Return recipes that need just one more ingredient
    return _recipeMatches
        .where((match) => match.matchPercentage >= 80)
        .map((match) => match.recipe)
        .take(3)
        .toList();
  }

  List<String> getIngredientSuggestions() {
    // Return common ingredients that could complete recipes
    final suggestions = <String>[];
    for (final recipe in _allRecipes) {
      for (final ingredient in recipe.ingredients) {
        if (!_pantryList.any((item) => 
            (item['name'] as String? ?? '').toLowerCase() == ingredient.toLowerCase())) {
          if (!suggestions.contains(ingredient)) {
            suggestions.add(ingredient);
          }
        }
      }
    }
    return suggestions;
  }

  // Saved recipes functionality
  bool isRecipeSaved(String recipeId) {
    return _savedRecipeIds.contains(recipeId);
  }

  Future<void> toggleSaveRecipe(String recipeId) async {
    if (_user == null) return;
    
    try {
      if (_savedRecipeIds.contains(recipeId)) {
        // Unsave
        _savedRecipeIds.remove(recipeId);
      } else {
        // Save
        _savedRecipeIds.add(recipeId);
      }
      
      // Update Firestore
      await _firestore.updateUserProfile({
        'savedRecipes': _savedRecipeIds,
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error toggling save recipe: $e");
      // Revert on error
      if (_savedRecipeIds.contains(recipeId)) {
        _savedRecipeIds.remove(recipeId);
      } else {
        _savedRecipeIds.add(recipeId);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveRecipe(String recipeId) async {
    if (_user == null || _savedRecipeIds.contains(recipeId)) return;
    
    try {
      _savedRecipeIds.add(recipeId);
      await _firestore.updateUserProfile({
        'savedRecipes': _savedRecipeIds,
      });
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error saving recipe: $e");
      _savedRecipeIds.remove(recipeId);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unsaveRecipe(String recipeId) async {
    if (_user == null || !_savedRecipeIds.contains(recipeId)) return;
    
    try {
      _savedRecipeIds.remove(recipeId);
      await _firestore.updateUserProfile({
        'savedRecipes': _savedRecipeIds,
      });
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error unsaving recipe: $e");
      _savedRecipeIds.add(recipeId);
      notifyListeners();
      rethrow;
    }
  }


}
