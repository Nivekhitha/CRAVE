import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class PremiumService extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isPremium = false;
  bool _isLoading = false;

  // Getters
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;

  // Feature limits
  int get maxRecipes => _isPremium ? 999 : 10;
  int get maxPantryItems => _isPremium ? 999 : 50;
  bool get canUseVideoRecipes => _isPremium;
  bool get canUseFuzzyMatching => _isPremium;
  bool get canAutoGrocery => _isPremium;
  bool get canExportRecipes => _isPremium;
  bool get canUseAdvancedFilters => _isPremium;

  // Premium features list for UI
  List<PremiumFeature> get premiumFeatures => [
        PremiumFeature(
          title: 'Unlimited Recipes',
          description: 'Create and save unlimited recipes',
          icon: Icons.restaurant,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Advanced Matching',
          description: 'Smart ingredient matching with synonyms',
          icon: Icons.auto_awesome,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Auto-Grocery Lists',
          description: 'Automatically add missing ingredients',
          icon: Icons.shopping_cart,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Video Recipe Support',
          description: 'Import recipes from YouTube & Instagram',
          icon: Icons.play_circle,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Export Recipes',
          description: 'Share and backup your recipes',
          icon: Icons.share,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Advanced Filters',
          description: 'Filter by diet, cuisine, cook time',
          icon: Icons.filter_list,
          isEnabled: _isPremium,
        ),
      ];

  // Initialize premium status
  Future<void> initialize() async {
    await _loadPremiumStatus();
  }

  // Load premium status from Firestore
  Future<void> _loadPremiumStatus() async {
    try {
      final userId = _auth.userId;
      if (userId == null) return;

      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _isPremium = data['isPremium'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    }
  }

  // Simulated purchase (for testing)
  Future<void> unlockPremium() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      _isPremium = true;
      await _savePremiumStatus();

      debugPrint('✅ Premium unlocked successfully!');
    } catch (e) {
      debugPrint('❌ Premium unlock failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save premium status to Firestore
  Future<void> _savePremiumStatus() async {
    try {
      final userId = _auth.userId;
      if (userId == null) throw 'User not authenticated';

      await _db.collection('users').doc(userId).set({
        'isPremium': _isPremium,
        'premiumUnlockedAt': _isPremium ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving premium status: $e');
      rethrow;
    }
  }

  // Check if feature is available
  bool canUseFeature(String featureName) {
    switch (featureName) {
      case 'unlimited_recipes':
        return _isPremium;
      case 'video_recipes':
        return _isPremium;
      case 'fuzzy_matching':
        return _isPremium;
      case 'auto_grocery':
        return _isPremium;
      case 'export_recipes':
        return _isPremium;
      case 'advanced_filters':
        return _isPremium;
      default:
        return true; // Basic features are free
    }
  }

  // For testing - reset premium status
  Future<void> resetPremium() async {
    _isPremium = false;
    await _savePremiumStatus();
    notifyListeners();
  }

  // Get premium pricing info
  PremiumPricing get pricing => PremiumPricing(
        monthlyPrice: 4.99,
        yearlyPrice: 39.99,
        yearlySavings: 33,
      );
}

// Data classes
class PremiumFeature {
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;

  PremiumFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.isEnabled,
  });
}

class PremiumPricing {
  final double monthlyPrice;
  final double yearlyPrice;
  final int yearlySavings;

  PremiumPricing({
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.yearlySavings,
  });

  String get monthlyPriceFormatted => '\$${monthlyPrice.toStringAsFixed(2)}';
  String get yearlyPriceFormatted => '\$${yearlyPrice.toStringAsFixed(2)}';
}
