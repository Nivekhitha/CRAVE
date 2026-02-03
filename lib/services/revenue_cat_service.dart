import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// A clean, modular service for handling RevenueCat subscriptions.
/// Designed for the CRAVE competition demo.
class RevenueCatService {
  // TODO: Replace with your actual Public API Key from RevenueCat Dashboard
  static const _androidApiKey = 'goog_enfahxXZMWZpQLwdfVyPsWTGASG';

  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the RevenueCat SDK for Android.
  Future<void> init(String? userId) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      try {
        debugPrint('🚀 Initializing RevenueCat...');
        if (kDebugMode) {
          await Purchases.setLogLevel(LogLevel.debug);
        }

        PurchasesConfiguration configuration = PurchasesConfiguration(_androidApiKey);
        if (userId != null) {
          configuration.appUserID = userId;
        }
        
        await Purchases.configure(configuration);
        _isInitialized = true;
        debugPrint('✅ RevenueCat Initialized for user: ${userId ?? "anonymous"}');
      } catch (e) {
        debugPrint('❌ RevenueCat Initialization Error: $e');
        return;
      }
    }

    // If userId provided and different from current, log in
    if (userId != null) {
      await logIn(userId);
    }
  }

  /// Logs in the user to RevenueCat.
  Future<void> logIn(String userId) async {
    if (kIsWeb) return;
    try {
      debugPrint('🔑 Logging into RevenueCat with UID: $userId');
      LogInResult result = await Purchases.logIn(userId);
      debugPrint('🔑 RevenueCat Logged In: ${result.created ? "New User" : "Existing User"}');
    } catch (e) {
      debugPrint('❌ RevenueCat LogIn Error: $e');
    }
  }

  /// Logs out from RevenueCat.
  Future<void> logOut() async {
    if (kIsWeb) return;
    try {
      debugPrint('🚪 Logging out from RevenueCat');
      await Purchases.logOut();
    } catch (e) {
      debugPrint('❌ RevenueCat LogOut Error: $e');
    }
  }

  /// Fetches the current offering and returns the monthly package.
  Future<Package?> getMonthlyPackage() async {
    if (kIsWeb) return null;
    try {
      debugPrint('📡 Fetching offerings...');
      Offerings offerings = await Purchases.getOfferings();
      
      debugPrint('📦 Available Offerings: ${offerings.all.keys.join(", ")}');
      
      Offering? targetOffering = offerings.current;
      
      // Fallback 1: If current is null, check for "default"
      if (targetOffering == null && offerings.all.containsKey('default')) {
        debugPrint('⚠️ current offering is null, falling back to "default"');
        targetOffering = offerings.all['default'];
      }
      
      // Fallback 2: Take the first available if still null
      if (targetOffering == null && offerings.all.isNotEmpty) {
        debugPrint('⚠️ fallback to first available offering');
        targetOffering = offerings.all.values.first;
      }

      if (targetOffering == null) {
        debugPrint('❌ No offerings found');
        return null;
      }

      debugPrint('✅ Selected Offering: ${targetOffering.identifier}');
      debugPrint('📦 Available Packages in ${targetOffering.identifier}: ${targetOffering.availablePackages.map((p) => p.packageType).join(", ")}');

      // Try to find a monthly package
      Package? monthly = targetOffering.monthly;
      
      // Fallback: If .monthly is null, look through availablePackages for Monthly type
      if (monthly == null) {
        debugPrint('⚠️ .monthly is null, searching availablePackages...');
        try {
          monthly = targetOffering.availablePackages.firstWhere(
            (p) => p.packageType == PackageType.monthly,
          );
        } catch (_) {
          // If no monthly, maybe just take the first one available as a desperate fallback
          if (targetOffering.availablePackages.isNotEmpty) {
            debugPrint('⚠️ No monthly type found, falling back to first package');
            monthly = targetOffering.availablePackages.first;
          }
        }
      }

      if (monthly != null) {
        debugPrint('✅ Found Package: ${monthly.identifier} - Price: ${monthly.storeProduct.priceString}');
      } else {
        debugPrint('❌ No suitable package found in offering');
      }

      return monthly;
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
    }
    return null;
  }

  /// Handles the purchase flow for a specific package.
  Future<bool> purchasePackage(Package package) async {
    if (kIsWeb) return false;
    try {
      debugPrint('💸 Starting purchase for: ${package.identifier}');
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      
      bool isActive = customerInfo.entitlements.all['CRAVE Pro']?.isActive ?? false;
      debugPrint('💳 Purchase result: ${isActive ? "SUCCESS" : "FAILED/CANCELLED"}');
      return isActive;
    } catch (e) {
      debugPrint('❌ Purchase Error: $e');
      return false;
    }
  }

  /// Checks if the user has an active "CRAVE Pro" entitlement.
  Future<bool> isPremiumUser() async {
    if (kIsWeb) return false;
    try {
      debugPrint('🔍 Checking entitlement: CRAVE Pro');
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      bool isActive = customerInfo.entitlements.all['CRAVE Pro']?.isActive ?? false;
      debugPrint('👑 Premium Status: $isActive');
      return isActive;
    } catch (e) {
      debugPrint('❌ Entitlement Check Error: $e');
      return false;
    }
  }

  /// Restores previous purchases.
  Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    try {
      debugPrint('🔄 Restoring purchases...');
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      bool isActive = customerInfo.entitlements.all['CRAVE Pro']?.isActive ?? false;
      debugPrint('🔄 Restore result: ${isActive ? "SUCCESS" : "NO PURCHASES FOUND"}');
      return isActive;
    } catch (e) {
      debugPrint('❌ Restore Error: $e');
      return false;
    }
  }
}
