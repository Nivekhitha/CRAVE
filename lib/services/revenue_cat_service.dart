import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Result wrapper for RevenueCat operations
class RevenueCatResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  RevenueCatResult.success(this.data) : isSuccess = true, error = null;
  RevenueCatResult.error(this.error) : isSuccess = false, data = null;
}

/// A clean, modular service for handling RevenueCat subscriptions.
/// Wraps the official SDK to provide a simplified interface for the app.
/// NO mock logic - only real RevenueCat operations.
class RevenueCatService {
  static const _androidApiKey = 'goog_enfahxXZMWZpQLwdfVyPsWTGASG';

  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the RevenueCat SDK.
  /// Returns success/error status only - no mock logic.
  Future<RevenueCatResult<void>> init(String? userId) async {
    if (_isInitialized || kIsWeb) {
      return RevenueCatResult.success(null);
    }

    try {
      debugPrint('🚀 Initializing RevenueCat...');
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final apiKey = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? _androidApiKey;
      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
      if (userId != null) {
        configuration.appUserID = userId;
      }
      
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('✅ RevenueCat Initialized');
      return RevenueCatResult.success(null);
    } catch (e) {
      debugPrint('❌ RevenueCat Initialization Error: $e');
      return RevenueCatResult.error('Failed to initialize RevenueCat: $e');
    }
  }

  /// Fetches current offerings and returns result with status.
  Future<RevenueCatResult<Offerings>> getOfferings() async {
    if (kIsWeb) {
      return RevenueCatResult.error('RevenueCat not supported on web');
    }
    
    if (!_isInitialized) {
      return RevenueCatResult.error('RevenueCat not initialized');
    }

    try {
      Offerings offerings = await Purchases.getOfferings();
      
      if (offerings.current == null && offerings.all.isEmpty) {
        debugPrint('⚠️ No offerings found in RevenueCat. Check Console configuration.');
        return RevenueCatResult.error('No offerings configured');
      }

      debugPrint('✅ Retrieved ${offerings.all.length} offerings');
      return RevenueCatResult.success(offerings);
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return RevenueCatResult.error('Failed to fetch offerings: $e');
    }
  }

  /// Fetches the current offering and returns the monthly package.
  Future<RevenueCatResult<Package>> getMonthlyPackage() async {
    final offeringsResult = await getOfferings();
    if (!offeringsResult.isSuccess) {
      return RevenueCatResult.error(offeringsResult.error);
    }

    final offerings = offeringsResult.data!;
    if (offerings.current?.monthly != null) {
      return RevenueCatResult.success(offerings.current!.monthly!);
    }

    return RevenueCatResult.error('Monthly package not found');
  }

  /// Fetches the current offering and returns the yearly package.
  Future<RevenueCatResult<Package>> getYearlyPackage() async {
    final offeringsResult = await getOfferings();
    if (!offeringsResult.isSuccess) {
      return RevenueCatResult.error(offeringsResult.error);
    }

    final offerings = offeringsResult.data!;
    if (offerings.current?.annual != null) {
      return RevenueCatResult.success(offerings.current!.annual!);
    }

    return RevenueCatResult.error('Yearly package not found');
  }

  /// Attempts to purchase a package.
  /// Returns success/error status only.
  Future<RevenueCatResult<CustomerInfo>> purchasePackage(Package package) async {
    if (kIsWeb) {
      return RevenueCatResult.error('Purchases not supported on web');
    }
    
    if (!_isInitialized) {
      return RevenueCatResult.error('RevenueCat not initialized');
    }

    try {
      debugPrint('💸 Starting purchase for: ${package.identifier}');
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      debugPrint('✅ Purchase completed successfully');
      return RevenueCatResult.success(customerInfo);
    } catch (e) {
      debugPrint('❌ Purchase Error: $e');
      return RevenueCatResult.error('Purchase failed: $e');
    }
  }

  /// Checks if the user has an active premium entitlement.
  /// Returns success/error status with boolean result.
  Future<RevenueCatResult<bool>> isPremiumUser() async {
    if (kIsWeb) {
      return RevenueCatResult.error('RevenueCat not supported on web');
    }
    
    if (!_isInitialized) {
      return RevenueCatResult.error('RevenueCat not initialized');
    }

    try {
      debugPrint('🔍 Checking entitlement: CRAVE Pro');
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final isPremium = _checkEntitlement(customerInfo);
      return RevenueCatResult.success(isPremium);
    } catch (e) {
      debugPrint('❌ Entitlement Check Error: $e');
      return RevenueCatResult.error('Failed to check premium status: $e');
    }
  }

  /// Restores previous purchases.
  /// Returns success/error status with boolean result.
  Future<RevenueCatResult<bool>> restorePurchases() async {
    if (kIsWeb) {
      return RevenueCatResult.error('Purchases not supported on web');
    }
    
    if (!_isInitialized) {
      return RevenueCatResult.error('RevenueCat not initialized');
    }

    try {
      debugPrint('🔄 Restoring purchases...');
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      final isPremium = _checkEntitlement(customerInfo);
      debugPrint('✅ Restore completed, premium status: $isPremium');
      return RevenueCatResult.success(isPremium);
    } catch (e) {
      debugPrint('❌ Restore Error: $e');
      return RevenueCatResult.error('Failed to restore purchases: $e');
    }
  }

  /// Internal method to check entitlement status
  bool _checkEntitlement(CustomerInfo info) {
    // Check for 'CRAVE Pro', 'pro', 'premium', or 'plus'
    // in case entitlement name changes in dashboard
    final entitlements = info.entitlements.all;
    return (entitlements['CRAVE Pro']?.isActive ?? false) ||
           (entitlements['pro']?.isActive ?? false) ||
           (entitlements['premium']?.isActive ?? false);
  }
}
