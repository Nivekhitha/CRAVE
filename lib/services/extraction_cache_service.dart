import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../models/extraction_result.dart';

/// Multi-layer cache service for recipe extraction results
/// Cache hierarchy: Hive (local) -> Firestore (cloud) -> Fresh extraction
class ExtractionCacheService {
  static const String _hiveBoxName = 'extraction_cache';
  static const String _firestoreCollection = 'extraction_cache';
  static const Duration _cacheExpiry = Duration(days: 30);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Box<dynamic>? _hiveBox;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _hiveBox = await Hive.openBox(_hiveBoxName);
      debugPrint("✅ Extraction cache initialized");
    } catch (e) {
      debugPrint("⚠️ Failed to initialize extraction cache: $e");
    }
  }

  /// Get cached extraction result by hash
  /// Returns null if not found or expired
  Future<ExtractionResult?> getCached(String contentHash) async {
    // 1. Try Hive cache first (fastest)
    final hiveResult = await _getFromHive(contentHash);
    if (hiveResult != null) {
      debugPrint("⚡ HIVE CACHE HIT for $contentHash");
      return hiveResult;
    }

    // 2. Try Firestore cache (slower but shared across devices)
    final firestoreResult = await _getFromFirestore(contentHash);
    if (firestoreResult != null) {
      debugPrint("☁️ FIRESTORE CACHE HIT for $contentHash");
      
      // Store in Hive for next time (fire-and-forget)
      _saveToHive(contentHash, firestoreResult).catchError((e) {
        debugPrint("⚠️ Failed to save Firestore result to Hive: $e");
      });
      
      return firestoreResult;
    }

    debugPrint("❌ CACHE MISS for $contentHash");
    return null;
  }

  /// Save extraction result to both cache layers
  Future<void> saveToCache(String contentHash, ExtractionResult result, {String? sourceInfo}) async {
    final cacheData = {
      'hash': contentHash,
      'recipes': result.recipes.map((r) => r.toMap()).toList(),
      'extractedAt': result.extractedAt.toIso8601String(),
      'sourceInfo': sourceInfo,
      'warnings': result.warnings,
      'totalChunks': result.totalChunksProcessed,
    };

    // Save to both layers (fire-and-forget for better UX)
    _saveToHive(contentHash, result).catchError((e) {
      debugPrint("⚠️ Failed to save to Hive cache: $e");
    });

    _saveToFirestore(contentHash, cacheData).catchError((e) {
      debugPrint("⚠️ Failed to save to Firestore cache: $e");
    });
  }

  /// Get from Hive cache
  Future<ExtractionResult?> _getFromHive(String contentHash) async {
    try {
      if (_hiveBox == null) return null;

      final data = _hiveBox!.get(contentHash);
      if (data == null) return null;

      final Map<String, dynamic> cacheData = Map<String, dynamic>.from(data);
      
      // Check expiry
      final extractedAt = DateTime.parse(cacheData['extractedAt']);
      if (DateTime.now().difference(extractedAt) > _cacheExpiry) {
        // Expired, remove from cache
        _hiveBox!.delete(contentHash);
        return null;
      }

      // Parse recipes
      final List<dynamic> recipesJson = cacheData['recipes'] ?? [];
      final recipes = recipesJson.map((json) => Recipe.fromMap(json, json['id'])).toList();

      return ExtractionResult.fromCache(
        recipes: recipes,
        cacheSource: 'hive',
        extractedAt: extractedAt,
        sourceInfo: cacheData['sourceInfo'],
        warnings: List<String>.from(cacheData['warnings'] ?? []),
      );
    } catch (e) {
      debugPrint("⚠️ Error reading from Hive cache: $e");
      return null;
    }
  }

  /// Get from Firestore cache
  Future<ExtractionResult?> _getFromFirestore(String contentHash) async {
    try {
      final doc = await _firestore
          .collection(_firestoreCollection)
          .doc(contentHash)
          .get()
          .timeout(const Duration(seconds: 5));

      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      
      // Check expiry
      final Timestamp? timestamp = data['createdAt'];
      if (timestamp != null) {
        final extractedAt = timestamp.toDate();
        if (DateTime.now().difference(extractedAt) > _cacheExpiry) {
          // Expired, remove from cache (fire-and-forget)
          _firestore.collection(_firestoreCollection).doc(contentHash).delete().catchError((e) {
            debugPrint("⚠️ Failed to delete expired Firestore cache: $e");
          });
          return null;
        }
      }

      // Parse recipes
      final List<dynamic> recipesJson = data['recipes'] ?? [];
      final recipes = recipesJson.map((json) => Recipe.fromMap(json, json['id'])).toList();

      return ExtractionResult.fromCache(
        recipes: recipes,
        cacheSource: 'firestore',
        extractedAt: timestamp?.toDate() ?? DateTime.now(),
        sourceInfo: data['sourceInfo'],
        warnings: List<String>.from(data['warnings'] ?? []),
      );
    } catch (e) {
      debugPrint("⚠️ Error reading from Firestore cache: $e");
      return null;
    }
  }

  /// Save to Hive cache
  Future<void> _saveToHive(String contentHash, ExtractionResult result) async {
    try {
      if (_hiveBox == null) return;

      final cacheData = {
        'hash': contentHash,
        'recipes': result.recipes.map((r) => r.toMap()).toList(),
        'extractedAt': result.extractedAt.toIso8601String(),
        'sourceInfo': result.sourceInfo,
        'warnings': result.warnings,
        'totalChunks': result.totalChunksProcessed,
      };

      await _hiveBox!.put(contentHash, cacheData);
      debugPrint("💾 Saved to Hive cache: $contentHash");
    } catch (e) {
      debugPrint("⚠️ Error saving to Hive cache: $e");
    }
  }

  /// Save to Firestore cache
  Future<void> _saveToFirestore(String contentHash, Map<String, dynamic> cacheData) async {
    try {
      cacheData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_firestoreCollection)
          .doc(contentHash)
          .set(cacheData)
          .timeout(const Duration(seconds: 10));
      
      debugPrint("☁️ Saved to Firestore cache: $contentHash");
    } catch (e) {
      debugPrint("⚠️ Error saving to Firestore cache: $e");
    }
  }

  /// Clear all caches (for debugging/testing)
  Future<void> clearAllCaches() async {
    try {
      // Clear Hive
      if (_hiveBox != null) {
        await _hiveBox!.clear();
        debugPrint("🧹 Cleared Hive cache");
      }

      // Clear Firestore (batch delete)
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(_firestoreCollection).get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint("🧹 Cleared Firestore cache");
    } catch (e) {
      debugPrint("⚠️ Error clearing caches: $e");
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      int hiveCount = 0;
      int firestoreCount = 0;

      // Count Hive entries
      if (_hiveBox != null) {
        hiveCount = _hiveBox!.length;
      }

      // Count Firestore entries
      try {
        final snapshot = await _firestore
            .collection(_firestoreCollection)
            .count()
            .get()
            .timeout(const Duration(seconds: 5));
        firestoreCount = snapshot.count ?? 0;
      } catch (e) {
        debugPrint("⚠️ Failed to get Firestore count: $e");
      }

      return {
        'hiveEntries': hiveCount,
        'firestoreEntries': firestoreCount,
        'cacheExpiry': _cacheExpiry.inDays,
      };
    } catch (e) {
      debugPrint("⚠️ Error getting cache stats: $e");
      return {'error': e.toString()};
    }
  }
}