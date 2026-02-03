import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A clean, modular service for handling RevenueCat subscriptions.
/// Wraps the official SDK to provide a simplified interface for the app.
class RevenueCatService {
  // Key should ideally be in .env, but for now we keep it here for simplicity
  // unless .env is fully set up.
  static const _androidApiKey = 'goog_enfahxXZMWZpQLwdfVyPsWTGASG';

  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize the RevenueCat SDK.
  Future<void> init(String? userId) async {
    if (_isInitialized || kIsWeb) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Check for .env key first, fallback to static
      final apiKey = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? _androidApiKey;

      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
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
      
      // Log offerings for debugging
      if (offerings.current == null && offerings.all.isEmpty) {
        debugPrint('⚠️ No offerings found in RevenueCat. Check Console configuration.');
      }

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
      return _checkEntitlement(customerInfo);
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
      return _checkEntitlement(customerInfo);
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
      return _checkEntitlement(customerInfo);
    } catch (e) {
      debugPrint('❌ Restore Error: $e');
      return false;
    }
  }
  
  bool _checkEntitlement(CustomerInfo info) {
    // Check for 'CRAVE Pro', 'pro', 'premium', or 'plus'
    // in case entitlement name changes in dashboard
    final entitlements = info.entitlements.all;
    return (entitlements['CRAVE Pro']?.isActive ?? false) ||
           (entitlements['pro']?.isActive ?? false) ||
           (entitlements['premium']?.isActive ?? false);
  }
}
