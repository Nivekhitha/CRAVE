import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../utils/exceptions.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  // Singleton
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal() {
    // Enable offline persistence (default in newer SDK versions, but explicit is good)
    _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  // --- Helpers ---

  String? get _userId => _auth.userId;

  DocumentReference _userDoc() {
    if (_userId == null) throw 'User not authenticated';
    return _db.collection('users').doc(_userId);
  }

  Future<DocumentSnapshot> getUserDoc(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // --- User Profile ---

  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String country,
    required String email,
  }) async {
    await _perform(() async {
      await _db.collection('users').doc(uid).set({
        'username': username,
        'country': country,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isPremium': false, // Default to free tier
      }, SetOptions(merge: true));
    });
  }

  // --- Generic Error Handling ---

  Future<T> _perform<T>(Future<T> Function() operation) async {
    try {
      return await operation().timeout(const Duration(seconds: 10));
    } on FirebaseException catch (e) {
      debugPrint('🔥 Firestore Error [${e.code}]: ${e.message}');

      // Handle specific offline scenarios
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        debugPrint(
            '📱 Device appears to be offline. Data will sync when connection is restored.');
        throw OfflineException(
            'You\'re offline. Changes will sync when you\'re back online.');
      }

      if (e.code == 'permission-denied') {
        throw AuthException('Permission denied. Please sign in again.');
      }

      if (e.code == 'not-found') {
        throw DataException('Data not found. It may have been deleted.');
      }

      throw FirestoreException('Database error: ${e.message}');
    } catch (e) {
      debugPrint('❌ General Error: $e');

      // Check if it's a timeout (likely offline)
      if (e.toString().contains('TimeoutException')) {
        debugPrint('📱 Connection timeout. Check your internet connection.');
        throw OfflineException(
            'Connection timeout. Please check your internet connection.');
      }

      // Check if it's our string error (e.g. 'User not authenticated')
      if (e.toString() == 'User not authenticated') {
        throw AuthException('You must be logged in to perform this action.');
      }

      // Check if it's our custom exception
      if (e is AppException) {
        rethrow;
      }

      throw NetworkException('Connection failed. Please check your internet. ($e)');
    }
  }

  // --- Pantry / Fridge ---

  Stream<QuerySnapshot> getPantryStream() {
    if (_userId == null) return const Stream.empty();
    return _userDoc()
        .collection('pantry')
        .orderBy('addedDate', descending: true)
        .snapshots();
  }

  Future<void> addPantryItem(Map<String, dynamic> itemData) async {
    await _perform(() async {
      final docRef = _userDoc().collection('pantry').doc();
      itemData['id'] = docRef.id;
      itemData['addedDate'] = FieldValue.serverTimestamp();
      await docRef.set(itemData);
    });
  }

  Future<void> updatePantryItem(
      String itemId, Map<String, dynamic> updates) async {
    await _perform(() async {
      await _userDoc().collection('pantry').doc(itemId).update(updates);
    });
  }

  Future<void> deletePantryItem(String itemId) async {
    await _perform(() async {
      await _userDoc().collection('pantry').doc(itemId).delete();
    });
  }

  // --- Grocery List ---

  Stream<QuerySnapshot> getGroceryStream() {
    if (_userId == null) return const Stream.empty();
    return _userDoc()
        .collection('grocery_list')
        .orderBy('isChecked') // Checked items at bottom
        .orderBy('addedDate', descending: true)
        .snapshots();
  }

  Future<void> addGroceryItem(Map<String, dynamic> itemData) async {
    await _perform(() async {
      final docRef = _userDoc().collection('grocery_list').doc();
      itemData['id'] = docRef.id;
      itemData['addedDate'] = FieldValue.serverTimestamp();
      await docRef.set(itemData);
    });
  }

  Future<void> updateGroceryItem(
      String itemId, Map<String, dynamic> updates) async {
    await _perform(() async {
      await _userDoc().collection('grocery_list').doc(itemId).update(updates);
    });
  }

  Future<void> deleteGroceryItem(String itemId) async {
    await _perform(() async {
      await _userDoc().collection('grocery_list').doc(itemId).delete();
    });
  }

  // --- Recipes (User Saved/Created) ---

  Stream<QuerySnapshot> getSavedRecipesStream() {
    if (_userId == null) return const Stream.empty();
    return _userDoc()
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Public / Global Recipes ---
  Stream<QuerySnapshot> getPublicRecipesStream() {
    return _db
        .collection('recipes')
        // .where('isPublic', isEqualTo: true) // optional: if we have a flag
        .limit(50) // Limit for MVP performance
        .snapshots();
  }

  Future<void> saveRecipe(Map<String, dynamic> recipeData) async {
    await _perform(() async {
      String id = recipeData['id'] ?? _userDoc().collection('recipes').doc().id;
      recipeData['createdAt'] = FieldValue.serverTimestamp();
      await _userDoc().collection('recipes').doc(id).set(recipeData);
    });
  }
}
