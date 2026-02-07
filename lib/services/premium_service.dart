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
  
  late final AuthService? _auth;
  late final FirebaseFirestore? _db;
  bool _firebaseAvailable = false;
  final RevenueCatService _rcService = RevenueCatService();

  // Single source of truth for premium status
  final ValueNotifier<bool> _isPremiumNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isPremium => _isPremiumNotifier;
  
  bool _isLoading = false;
  bool _isMockMode = false;
  bool _isInitialized = false;
  Package? _monthlyPackage;
  Package? _yearlyPackage;
  Box? _premiumBox;
  Box? _trialBox;

  // Getters
  bool get isLoading => _isLoading;
  bool get isMockMode => _isMockMode;
  bool get isInitialized => _isInitialized;
  String get monthlyPrice => _monthlyPackage?.storeProduct.priceString ?? "\$4.99";
  String get yearlyPrice => _yearlyPackage?.storeProduct.priceString ?? "\$39.99";

  // Feature limits
  int get maxRecipes => _isPremiumNotifier.value ? 999 : 10;
  int get maxPantryItems => _isPremiumNotifier.value ? 999 : 50;
  bool get canUseVideoRecipes => _isPremiumNotifier.value;
  bool get canUseFuzzyMatching => _isPremiumNotifier.value;
  bool get canAutoGrocery => _isPremiumNotifier.value;
  bool get canExportRecipes => _isPremiumNotifier.value;
  bool get canUseAdvancedFilters => _isPremiumNotifier.value;
  bool get canUseJournal => _isPremiumNotifier.value || isEmotionalCookingTrialActive;
  bool get canUseMealPlanning => _isPremiumNotifier.value || isEmotionalCookingTrialActive;
  bool get canUseNutritionDashboard => _isPremiumNotifier.value;
  bool get canUseAIDietitian => _isPremiumNotifier.value;

  // Premium features list for UI
  List<PremiumFeature> get premiumFeatures => [
        PremiumFeature(
          title: 'Personal AI Dietitian',
          description: 'Get personalized nutrition advice and meal recommendations',
          icon: Icons.psychology,
          isEnabled: _isPremiumNotifier.value,
        ),
        PremiumFeature(
          title: 'Food Journal',
          description: 'Track your meals and nutrition with detailed insights',
          icon: Icons.book,
          isEnabled: _isPremiumNotifier.value,
        ),
        PremiumFeature(
          title: 'Meal Planning',
          description: 'Plan your weekly meals with smart suggestions',
          icon: Icons.calendar_today,
          isEnabled: _isPremiumNotifier.value,
        ),
        PremiumFeature(
          title: 'Nutrition Dashboard',
          description: 'Comprehensive nutrition tracking and analytics',
          icon: Icons.analytics,
          isEnabled: _isPremiumNotifier.value,
        ),
        PremiumFeature(
          title: 'Unlimited Recipes',
          description: 'Create and save unlimited recipes',
          icon: Icons.restaurant,
          isEnabled: _isPremiumNotifier.value,
        ),
        PremiumFeature(
          title: 'Video Recipe Support',
          description: 'Import recipes from YouTube & Instagram',
          icon: Icons.play_circle,
          isEnabled: _isPremiumNotifier.value,
        ),
      ];

  /// Initialize premium status and RevenueCat
  /// This is the main init method that loads saved state and sets up RevenueCat
  Future<void> init() async {
    await _initHive();
    await _loadLocalPremiumStatus();
    
    // Check if Firebase is available
    try {
      final authService = AuthService();
      if (!authService.isAvailable) {
        throw Exception('Firebase Auth not available');
      }
      _auth = authService;
      _db = FirebaseFirestore.instance;
      _firebaseAvailable = true;
      debugPrint('✅ Firebase services available for PremiumService');
    } catch (e) {
      debugPrint('⚠️ Firebase not available for PremiumService: $e');
      _auth = null;
      _db = null;
      _firebaseAvailable = false;
      _isMockMode = true;
    }
    
    final userId = _firebaseAvailable ? _auth?.userId : null;
    final rcInitResult = await _rcService.init(userId);
    
    if (rcInitResult.isSuccess) {
      await _refreshFromRevenueCat();
    } else {
      debugPrint('⚠️ RevenueCat init failed: ${rcInitResult.error}');
      _isMockMode = true;
      debugPrint('🛡️ Mock mode enabled');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Legacy method for backward compatibility
  Future<void> initialize() async {
    await init();
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
      final savedStatus = _premiumBox?.get('isPremium', defaultValue: false) ?? false;
      _isPremiumNotifier.value = savedStatus;
      debugPrint('📱 Loaded local premium status: ${_isPremiumNotifier.value}');
    } catch (e) {
      debugPrint('❌ Error loading local premium status: $e');
    }
  }

  /// Refreshes the premium status from RevenueCat and updates local state
  Future<void> _refreshFromRevenueCat() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check RevenueCat Entitlement (if available)
      final premiumResult = await _rcService.isPremiumUser();
      bool rcPremium = false;
      
      if (premiumResult.isSuccess) {
        rcPremium = premiumResult.data ?? false;
      } else {
        debugPrint('⚠️ Failed to check premium status: ${premiumResult.error}');
        _isMockMode = true;
      }
      
      // 2. Fetch current offerings for UI
      final monthlyResult = await _rcService.getMonthlyPackage();
      final yearlyResult = await _rcService.getYearlyPackage();
      
      if (monthlyResult.isSuccess) {
        _monthlyPackage = monthlyResult.data;
      }
      if (yearlyResult.isSuccess) {
        _yearlyPackage = yearlyResult.data;
      }
      
      // If no packages available, enable mock mode
      if (_monthlyPackage == null && _yearlyPackage == null) {
        _isMockMode = true;
        debugPrint('🛡️ No packages available, mock mode enabled');
      }
      
      // 3. Update premium status (RevenueCat takes precedence)
      if (rcPremium != _isPremiumNotifier.value) {
        _isPremiumNotifier.value = rcPremium;
        await _savePremiumStatusLocally();
        
        // 4. Sync with Firestore (fire-and-forget)
        if (_isPremiumNotifier.value) {
          _savePremiumStatusToFirestore(); // No await - fire and forget
        }
      }
      
    } catch (e) {
      debugPrint('❌ Error refreshing premium status: $e');
      _isMockMode = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Legacy method for backward compatibility
  Future<void> refreshStatus() async {
    await _refreshFromRevenueCat();
  }

  /// Purchase premium with mock mode fallback
  /// This is the main purchase method that handles both real and mock purchases
  Future<PurchaseResult> purchasePremium({bool isYearly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try real purchase if RevenueCat is available and not in mock mode
      if (_rcService.isInitialized && !_isMockMode) {
        final package = isYearly ? _yearlyPackage : _monthlyPackage;
        
        if (package != null) {
          final purchaseResult = await _rcService.purchasePackage(package);
          
          if (purchaseResult.isSuccess) {
            _isPremiumNotifier.value = true;
            notifyListeners();
            await _savePremiumStatusLocally();
            _savePremiumStatusToFirestore(); // Fire-and-forget
            return PurchaseResult.success();
          } else {
            if (!kDebugMode) return PurchaseResult.error(purchaseResult.error ?? 'Purchase failed');
          }
        }
      }

      // 2. Mock Purchase Flow (Debug/Demo Mode)
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Grant premium access locally
      _isPremiumNotifier.value = true;
      
      // Immediately notify all listeners
      notifyListeners();
      
      // Save to local storage
      await _savePremiumStatusLocally();
      
      // Save to Firestore (fire-and-forget)
      _savePremiumStatusToFirestore();
      
      return PurchaseResult.success();
      
    } catch (e) {
      return PurchaseResult.error('Purchase failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Legacy method for backward compatibility
  Future<PurchaseResult> unlockPremium({bool isYearly = false}) async {
    return await purchasePremium(isYearly: isYearly);
  }

  /// Restore purchases for existing users
  Future<bool> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_rcService.isInitialized && !_isMockMode) {
        final restoreResult = await _rcService.restorePurchases();
        if (restoreResult.isSuccess && restoreResult.data == true) {
          _isPremiumNotifier.value = true;
          await _savePremiumStatusLocally();
          _savePremiumStatusToFirestore(); // Fire-and-forget
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
    if (_isPremiumNotifier.value) return true; // Premium users always have access
    
    try {
      final firstOpenedAt = _trialBox?.get('firstOpenedAt');
      if (firstOpenedAt == null) {
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
    if (_isPremiumNotifier.value) return 0;
    
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
      await _premiumBox?.put('isPremium', _isPremiumNotifier.value);
      await _premiumBox?.put('lastUpdated', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Error saving premium status locally: $e');
    }
  }

  /// Save premium status to Firestore
  Future<void> _savePremiumStatusToFirestore() async {
    if (!_firebaseAvailable) {
      debugPrint('⚠️ Firebase not available, skipping Firestore save');
      return;
    }
    
    try {
      final userId = _auth?.userId;
      if (userId == null) return;

      await _db!.collection('users').doc(userId).set({
        'isPremium': _isPremiumNotifier.value,
        'premiumUnlockedAt': _isPremiumNotifier.value ? FieldValue.serverTimestamp() : null,
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
        return _isPremiumNotifier.value;
      case 'video_recipes':
        return _isPremiumNotifier.value;
      case 'fuzzy_matching':
        return _isPremiumNotifier.value;
      case 'auto_grocery':
        return _isPremiumNotifier.value;
      case 'export_recipes':
        return _isPremiumNotifier.value;
      case 'advanced_filters':
        return _isPremiumNotifier.value;
      default:
        return true; // Basic features are free
    }
  }

  /// For testing - reset premium status
  Future<void> resetPremium() async {
    _isPremiumNotifier.value = false;
    await _savePremiumStatusLocally();
    _savePremiumStatusToFirestore(); // Fire-and-forget
    notifyListeners();
  }

  /// For testing - reset trial
  Future<void> resetTrial() async {
    await _trialBox?.delete('firstOpenedAt');
    notifyListeners();
  }

  /// Get premium pricing info
  PremiumPricing get pricing => PremiumPricing(
        monthlyPriceString: monthlyPrice,
        yearlyPriceString: "Coming Soon", // Or fetch yearly package
        yearlySavings: 33,
      );

  @override
  void dispose() {
    _isPremiumNotifier.dispose();
    super.dispose();
  }
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

