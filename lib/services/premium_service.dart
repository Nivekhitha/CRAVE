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
  bool get isOfferingsLoaded => _monthlyPackage != null;
  String get monthlyPrice => _monthlyPackage?.storeProduct.priceString ?? "No available price";

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
    debugPrint('🔔 PremiumService: Initializing...');
    
    // Listen to auth changes to sync with RevenueCat user IDs
    _auth.authStateChanges.listen((user) async {
      if (user != null) {
        debugPrint('🔔 PremiumService: Auth detected login, syncing UID: ${user.uid}');
        await _rcService.logIn(user.uid);
      } else {
        debugPrint('🔔 PremiumService: Auth detected logout, clearing UID');
        await _rcService.logOut();
      }
      await refreshStatus();
    });

    final userId = _auth.userId;
    await _rcService.init(userId);
    await refreshStatus();
  }

  /// Refreshes the premium status from RevenueCat and updates local state
  Future<void> refreshStatus() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔔 PremiumService: Refreshing status...');
      // 1. Check RevenueCat Entitlement
      _isPremium = await _rcService.isPremiumUser();
      
      // 2. Fetch current offerings for UI
      _monthlyPackage = await _rcService.getMonthlyPackage();
      
      if (_monthlyPackage != null) {
        debugPrint('🔔 PremiumService: Monthly package loaded: ${_monthlyPackage!.storeProduct.priceString}');
      } else {
        debugPrint('🔔 PremiumService: No monthly package found.');
      }
      
      // 3. Sync with Firestore (optional backup)
      if (_isPremium) {
        await _savePremiumStatus();
      }
    } catch (e) {
      debugPrint('❌ PremiumService: Error refreshing status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actual purchase flow through RevenueCat
  Future<void> unlockPremium() async {
    debugPrint('🔔 PremiumService: unlockPremium requested');
    
    if (_monthlyPackage == null) {
      debugPrint('🔔 PremiumService: Monthly package null, refreshing...');
      await refreshStatus();
    }
    
    if (_monthlyPackage == null) {
      debugPrint('❌ PremiumService: Still no packages available.');
      throw 'No subscription packages available. Please ensure you are on a real device with Google Play Store access.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _rcService.purchasePackage(_monthlyPackage!);
      if (success) {
        _isPremium = true;
        await _savePremiumStatus();
        debugPrint('✅ Premium unlocked successfully with RevenueCat!');
      } else {
        debugPrint('⚠️ PremiumService: Purchase not completed or failed.');
        throw 'Purchase was not completed.';
      }
    } catch (e) {
      debugPrint('❌ PremiumService: Premium unlock failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        debugPrint('✅ PremiumService: Purchases restored successfully.');
      }
    } catch (e) {
      debugPrint('❌ PremiumService: Restore failed: $e');
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
      if (userId == null) return; // Don't crash if no user

      await _db.collection('users').doc(userId).set({
        'isPremium': _isPremium,
        'premiumUnlockedAt': _isPremium ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ PremiumService: Error saving premium status to Firestore: $e');
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

  // Pricing model (Helper) - note: actual price comes from RevenueCat
  // But we still need these for UI display logic (yearly vs monthly calculation)
  // We should ideally fetch yearly package too if we want a real comparison.
  PremiumPricing get pricing => PremiumPricing(
        monthlyPriceString: monthlyPrice,
        yearlyPriceString: "Coming Soon", // Or fetch yearly package
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
  final String monthlyPriceString;
  final String yearlyPriceString;
  final int yearlySavings;

  PremiumPricing({
    required this.monthlyPriceString,
    required this.yearlyPriceString,
    required this.yearlySavings,
  });
}

