import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'auth_service.dart';
import 'revenue_cat_service.dart';

// Purchase result wrapper
class PurchaseResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? error;

  PurchaseResult.success() : isSuccess = true, isCancelled = false, error = null;
  PurchaseResult.cancelled() : isSuccess = false, isCancelled = true, error = null;
  PurchaseResult.error(this.error) : isSuccess = false, isCancelled = false;
}

class PremiumService extends ChangeNotifier {
  static const String _hiveBoxName = 'premium_v1';
  static const String _trialBoxName = 'trial_v1';
  
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RevenueCatService _rcService = RevenueCatService();

  bool _isPremium = false;
  bool _isLoading = false;
  Package? _monthlyPackage;
  Package? _yearlyPackage;
  Box? _premiumBox;
  Box? _trialBox;

  // Getters
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get monthlyPrice => _monthlyPackage?.storeProduct.priceString ?? "\$4.99";
  String get yearlyPrice => _yearlyPackage?.storeProduct.priceString ?? "\$39.99";

  // Feature limits
  int get maxRecipes => _isPremium ? 999 : 10;
  int get maxPantryItems => _isPremium ? 999 : 50;
  bool get canUseVideoRecipes => _isPremium;
  bool get canUseFuzzyMatching => _isPremium;
  bool get canAutoGrocery => _isPremium;
  bool get canExportRecipes => _isPremium;
  bool get canUseAdvancedFilters => _isPremium;
  bool get canUseJournal => _isPremium || isEmotionalCookingTrialActive;
  bool get canUseMealPlanning => _isPremium || isEmotionalCookingTrialActive;
  bool get canUseNutritionDashboard => _isPremium;
  bool get canUseAIDietitian => _isPremium;

  // Premium features list for UI
  List<PremiumFeature> get premiumFeatures => [
        PremiumFeature(
          title: 'Personal AI Dietitian',
          description: 'Get personalized nutrition advice and meal recommendations',
          icon: Icons.psychology,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Food Journal',
          description: 'Track your meals and nutrition with detailed insights',
          icon: Icons.book,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Meal Planning',
          description: 'Plan your weekly meals with smart suggestions',
          icon: Icons.calendar_today,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Nutrition Dashboard',
          description: 'Comprehensive nutrition tracking and analytics',
          icon: Icons.analytics,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Unlimited Recipes',
          description: 'Create and save unlimited recipes',
          icon: Icons.restaurant,
          isEnabled: _isPremium,
        ),
        PremiumFeature(
          title: 'Video Recipe Support',
          description: 'Import recipes from YouTube & Instagram',
          icon: Icons.play_circle,
          isEnabled: _isPremium,
        ),
      ];

  // Initialize premium status and RevenueCat
  Future<void> initialize() async {
    await _initHive();
    await _loadLocalPremiumStatus();
    
    final userId = _auth.userId;
    await _rcService.init(userId);
    await refreshStatus();
  }

  /// Initialize Hive boxes
  Future<void> _initHive() async {
    try {
      _premiumBox = await Hive.openBox(_hiveBoxName);
      _trialBox = await Hive.openBox(_trialBoxName);
    } catch (e) {
      debugPrint('❌ Error initializing premium Hive boxes: $e');
    }
  }

  /// Load premium status from local storage
  Future<void> _loadLocalPremiumStatus() async {
    try {
      _isPremium = _premiumBox?.get('isPremium', defaultValue: false) ?? false;
      debugPrint('📱 Loaded local premium status: $_isPremium');
    } catch (e) {
      debugPrint('❌ Error loading local premium status: $e');
    }
  }

  /// Refreshes the premium status from RevenueCat and updates local state
  Future<void> refreshStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check RevenueCat Entitlement (if available)
      bool rcPremium = false;
      if (_rcService.isInitialized) {
        rcPremium = await _rcService.isPremiumUser();
      }
      
      // 2. Fetch current offerings for UI
      if (_rcService.isInitialized) {
        _monthlyPackage = await _rcService.getMonthlyPackage();
        _yearlyPackage = await _rcService.getYearlyPackage();
      }
      
      // 3. Update premium status (RevenueCat takes precedence)
      if (rcPremium != _isPremium) {
        _isPremium = rcPremium;
        await _savePremiumStatusLocally();
        
        // 4. Sync with Firestore (optional backup)
        if (_isPremium) {
          await _savePremiumStatusToFirestore();
        }
      }
      
    } catch (e) {
      debugPrint('❌ Error refreshing premium status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase flow with mock mode fallback
  Future<PurchaseResult> unlockPremium({bool isYearly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get the appropriate package
      final package = isYearly ? _yearlyPackage : _monthlyPackage;
      
      // 2. Try real purchase if RevenueCat is available and package exists
      if (_rcService.isInitialized && package != null) {
        debugPrint("🛒 Attempting real purchase...");
        final result = await _rcService.purchasePackage(package);
        
        if (result) {
          _isPremium = true;
          await _savePremiumStatusLocally();
          await _savePremiumStatusToFirestore();
          debugPrint('✅ Premium unlocked successfully with RevenueCat!');
          return PurchaseResult.success();
        } else {
          debugPrint("⚠️ Real purchase failed");
          // In production, we'd return the error
          // In debug mode, fall through to mock
          if (!kDebugMode) return PurchaseResult.error('Purchase failed');
        }
      }

      // 3. Mock Purchase Flow (Debug/Demo Mode)
      debugPrint('🛡️ Using mock purchase flow (Demo Mode)');
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Grant premium access locally
      _isPremium = true;
      await _savePremiumStatusLocally();
      await _savePremiumStatusToFirestore();
      debugPrint('✅ Premium unlocked via mock flow!');
      
      return PurchaseResult.success();
      
    } catch (e) {
      debugPrint('❌ Premium unlock failed: $e');
      return PurchaseResult.error('Purchase failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore purchases for existing users
  Future<bool> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_rcService.isInitialized) {
        final success = await _rcService.restorePurchases();
        if (success) {
          _isPremium = true;
          await _savePremiumStatusLocally();
          await _savePremiumStatusToFirestore();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Restore purchases failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Trial Logic ---
  
  bool get isEmotionalCookingTrialActive {
    if (_isPremium) return true; // Premium users always have access
    
    try {
      final firstOpenedAt = _trialBox?.get('firstOpenedAt');
      if (firstOpenedAt == null) {
        // First time opening - start trial
        _trialBox?.put('firstOpenedAt', DateTime.now().millisecondsSinceEpoch);
        return true;
      }
      
      final firstOpened = DateTime.fromMillisecondsSinceEpoch(firstOpenedAt);
      final daysSinceFirst = DateTime.now().difference(firstOpened).inDays;
      
      return daysSinceFirst < 10; // 10-day trial
    } catch (e) {
      debugPrint('❌ Error checking trial status: $e');
      return false;
    }
  }

  int get trialDaysRemaining {
    if (_isPremium) return 0;
    
    try {
      final firstOpenedAt = _trialBox?.get('firstOpenedAt');
      if (firstOpenedAt == null) return 10;
      
      final firstOpened = DateTime.fromMillisecondsSinceEpoch(firstOpenedAt);
      final daysSinceFirst = DateTime.now().difference(firstOpened).inDays;
      
      return (10 - daysSinceFirst).clamp(0, 10);
    } catch (e) {
      return 0;
    }
  }

  /// Save premium status to local storage
  Future<void> _savePremiumStatusLocally() async {
    try {
      await _premiumBox?.put('isPremium', _isPremium);
      await _premiumBox?.put('lastUpdated', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Error saving premium status locally: $e');
    }
  }

  /// Save premium status to Firestore
  Future<void> _savePremiumStatusToFirestore() async {
    try {
      final userId = _auth.userId;
      if (userId == null) return;

      await _db.collection('users').doc(userId).set({
        'isPremium': _isPremium,
        'premiumUnlockedAt': _isPremium ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error saving premium status to Firestore: $e');
    }
  }

  /// Check if feature is available
  bool canUseFeature(String featureId) {
    switch (featureId) {
      case 'journal':
        return canUseJournal;
      case 'meal_planning':
        return canUseMealPlanning;
      case 'nutrition_dashboard':
        return canUseNutritionDashboard;
      case 'ai_dietitian':
        return canUseAIDietitian;
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

  /// For testing - reset premium status
  Future<void> resetPremium() async {
    _isPremium = false;
    await _savePremiumStatusLocally();
    await _savePremiumStatusToFirestore();
    notifyListeners();
  }

  /// For testing - reset trial
  Future<void> resetTrial() async {
    await _trialBox?.delete('firstOpenedAt');
    notifyListeners();
  }

  /// Get premium pricing info
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
