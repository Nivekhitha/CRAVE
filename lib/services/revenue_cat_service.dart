import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// A clean, modular service for handling RevenueCat subscriptions.
/// Designed for the CRAVE competition demo.
class RevenueCatService {
  // TODO: Replace with your actual Public API Key from RevenueCat Dashboard
  static const _androidApiKey = 'sk_iROILcbzCyhtncYZoSKgwqjQAoyXx';

  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize the RevenueCat SDK for Android.
  Future<void> init(String? userId) async {
    if (_isInitialized || kIsWeb) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      PurchasesConfiguration configuration = PurchasesConfiguration(_androidApiKey);
      if (userId != null) {
        configuration.appUserID = userId;
      }
      
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('✅ RevenueCat Initialized');
    } catch (e) {
      debugPrint('❌ RevenueCat Initialization Error: $e');
    }
  }

  /// Fetches the current offering and returns the monthly package.
  Future<Package?> getMonthlyPackage() async {
    if (kIsWeb) return null;
    try {
      Offerings offerings = await Purchases.getOfferings();
      // "default" is the identifier for your current offering
      if (offerings.current != null && offerings.current?.monthly != null) {
        return offerings.current!.monthly;
      }
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
    }
    return null;
  }

  /// Handles the purchase flow for a specific package.
  Future<bool> purchasePackage(Package package) async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      // Check if "CRAVE Pro" entitlement is active after purchase
      return customerInfo.entitlements.all['CRAVE Pro']?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ Purchase Error: $e');
      return false;
    }
  }

  /// Checks if the user has an active "CRAVE Pro" entitlement.
  Future<bool> isPremiumUser() async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['CRAVE Pro']?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ Entitlement Check Error: $e');
      return false;
    }
  }

  /// Restores previous purchases.
  Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['CRAVE Pro']?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ Restore Error: $e');
      return false;
    }
  }
}
