import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeCacheService {
  static const String _cacheKey = 'remote_recipe_cache';
  static const int _maxCacheSize = 50; // Keep last 50 discovered recipes

  static final RecipeCacheService _instance = RecipeCacheService._internal();
  factory RecipeCacheService() => _instance;
  RecipeCacheService._internal();

  /// Save a recipe to the local cache
  Future<void> cacheRemoteRecipe(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Recipe> cached = await getCachedRecipes();

      // Remove if already exists (to move it to top)
      cached.removeWhere((r) => r.id == recipe.id);

      // Add to top
      cached.insert(0, recipe);

      // Enforce limit
      if (cached.length > _maxCacheSize) {
        cached = cached.sublist(0, _maxCacheSize);
      }

      // Save
      final String jsonString = jsonEncode(cached.map((r) => r.toMap()).toList());
      await prefs.setString(_cacheKey, jsonString);
      
      debugPrint("💾 Cached remote recipe: ${recipe.title}");
    } catch (e) {
      debugPrint("❌ Error caching recipe: $e");
    }
  }

  /// Cache multiple recipes at once
  Future<void> cacheRemoteRecipes(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Recipe> cached = await getCachedRecipes();

      for (var recipe in recipes) {
        cached.removeWhere((r) => r.id == recipe.id);
        cached.insert(0, recipe);
      }

      if (cached.length > _maxCacheSize) {
        cached = cached.sublist(0, _maxCacheSize);
      }

      final String jsonString = jsonEncode(cached.map((r) => r.toMap()).toList());
      await prefs.setString(_cacheKey, jsonString);
       debugPrint("💾 Cached ${recipes.length} remote recipes");
    } catch (e) {
      debugPrint("❌ Error caching multiple recipes: $e");
    }
  }

  /// Load cached recipes from disk
  Future<List<Recipe>> getCachedRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Recipe.fromMap(json, json['id'])).toList();
    } catch (e) {
      debugPrint("❌ Error loading recipe cache: $e");
      return [];
    }
  }

  /// Clear cache (for testing/debug)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
