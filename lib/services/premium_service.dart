import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'auth_service.dart';
import 'revenue_cat_service.dart';

class PremiumService extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RevenueCatService _rcService = RevenueCatService();

  bool _isPremium = false;
  bool _isLoading = false;
  Package? _monthlyPackage;

  // Getters
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get monthlyPrice => _monthlyPackage?.storeProduct.priceString ?? "\$4.99";

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

  // Initialize premium status and RevenueCat
  Future<void> initialize() async {
    final userId = _auth.userId;
    await _rcService.init(userId);
    await refreshStatus();
  }

  /// Refreshes the premium status from RevenueCat and updates local state
  Future<void> refreshStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check RevenueCat Entitlement
      _isPremium = await _rcService.isPremiumUser();
      
      // 2. Fetch current offerings for UI
      _monthlyPackage = await _rcService.getMonthlyPackage();
      
      // 3. Sync with Firestore (optional backup)
      if (_isPremium) {
        await _savePremiumStatus();
      }
    } catch (e) {
      debugPrint('Error refreshing status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actual purchase flow through RevenueCat
  Future<void> unlockPremium() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try to fetch offerings if missing
      if (_monthlyPackage == null) {
        await refreshStatus();
      }

      // 2. Decide: Real Purchase or Mock Fallback?
      if (_monthlyPackage != null) {
         try {
            debugPrint("🛒 Attempting Real Purchase...");
            bool success = await _rcService.purchasePackage(_monthlyPackage!);
            if (success) {
              _isPremium = true;
              await _savePremiumStatus();
              debugPrint('✅ Premium unlocked successfully with RevenueCat!');
              return;
            } else {
              // User cancelled or specific failure that isn't an exception
              throw 'Purchase was not completed.';
            }
         } catch (e) {
            debugPrint("⚠️ Real Purchase Failed: $e");
            // If real purchase fails, fall through to mock logic below ONLY if in debug/mock mode
            if (!kDebugMode) rethrow; 
         }
      }

      // 3. Mock Purchase Flow (Fallback)
      // Triggers if: No offerings found OR Real purchase failed (in debug mode)
      debugPrint('🛡️ Initiating MOCK purchase flow (Demo/Fallback Mode).');
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Grant premium access locally
      _isPremium = true;
      await _savePremiumStatus();
      debugPrint('✅ Premium unlocked via MOCK flow!');
      
    } catch (e) {
      debugPrint('❌ Premium unlock failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Trial Logic ---
  
  bool get isEmotionalCookingTrialActive {
    if (_isPremium) return true; // Premium users always have access
    // TODO: Retrieve 'firstOpenedAt' from preferences/hive
    // For now, hardcode trial as active or simplistic check
    return true; // Giving free access for hackathon demo
  }

  /// Restore purchases for existing users
  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      bool success = await _rcService.restorePurchases();
      if (success) {
        _isPremium = true;
        await _savePremiumStatus();
      }
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
      case 'emotional_cooking':
         return isEmotionalCookingTrialActive;
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
