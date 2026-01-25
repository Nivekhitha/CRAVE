import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hive_service.dart';
import 'auth_service.dart';

class MigrationService {
  final HiveService _hiveService = HiveService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _migrationCompletedKey = 'has_migrated_to_firestore_v1';

  // Singleton
  static final MigrationService _instance = MigrationService._internal();
  factory MigrationService() => _instance;
  MigrationService._internal();

  /// Checks if migration is needed and performs it
  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool(_migrationCompletedKey) ?? false;

    if (hasMigrated) {
      debugPrint("✅ Data already migrated to Firestore.");
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      debugPrint("⚠️ Cannot migrate: User not logged in.");
      return;
    }

    debugPrint("🚀 Starting Migration for User: ${user.uid}...");
    try {
      await _performMigration(user.uid);
      await prefs.setBool(_migrationCompletedKey, true);
      
      // Optional: Clear Hive after successful migration?
      // await _hiveService.clearAllData(); 
      debugPrint("✅ Migration Complete!");
    } catch (e) {
      debugPrint("❌ Migration Failed: $e");
      // Don't set flag to true so we retry next time
    }
  }

  Future<void> _performMigration(String userId) async {
    final batch = _firestore.batch();
    final userDoc = _firestore.collection('users').doc(userId);

    // 1. Migrate Ingredients (Pantry)
    final ingredients = _hiveService.getAllIngredients();
    if (ingredients.isNotEmpty) {
      debugPrint("📦 Migrating ${ingredients.length} ingredients...");
      for (final ingredient in ingredients) {
        final docRef = userDoc.collection('pantry').doc(); // Auto-ID
        // Use the map but override ID with Firestore ID if we want them to match or just let Firestore generate
        // Better to let Firestore generate and fill data
        final data = ingredient.toMap();
        data['id'] = docRef.id; // Update ID to match doc
        data['migratedFromHive'] = true;
        batch.set(docRef, data);
      }
    }

    // 2. Migrate Grocery List
    final groceries = _hiveService.getAllGroceryItems();
    if (groceries.isNotEmpty) {
      debugPrint("📦 Migrating ${groceries.length} grocery items...");
      for (final item in groceries) {
        final docRef = userDoc.collection('grocery_list').doc();
        final data = item.toMap();
        data['id'] = docRef.id;
        data['migratedFromHive'] = true;
        batch.set(docRef, data);
      }
    }

    // 3. Migrate Recipes
    final recipes = _hiveService.getAllRecipes();
    if (recipes.isNotEmpty) {
      debugPrint("📦 Migrating ${recipes.length} recipes...");
      for (final recipe in recipes) {
        final docRef = userDoc.collection('recipes').doc();
        final data = recipe.toMap();
        data['id'] = docRef.id;
        data['migratedFromHive'] = true;
        batch.set(docRef, data);
      }
    }

    // Commit all writes
    await batch.commit();
  }
}
