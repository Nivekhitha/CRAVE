// Temporarily commented out due to RevenueCat compatibility issues
/*
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // TODO: Replace with your actual API Keys from RevenueCat Dashboard
  static const _apiKeyAndroid = 'goog_YOUR_ANDROID_API_KEY'; 
  static const _apiKeyIOS = 'appl_YOUR_IOS_API_KEY';

  // Singleton pattern
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize RevenueCat with the Firebase User ID
  Future<void> init(String userId) async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    } else {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    }

    configuration.appUserID = userId;
    await Purchases.configure(configuration);

    _isInitialized = true;
    print('✅ RevenueCat initialized for User ID: $userId');
  }

  /// Check if the user has an active premium entitlement
  Future<bool> isPremiumUser() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // 'premium' is the identifier you set in RevenueCat Entitlements
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      print('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Trigger the purchase flow for the monthly package
  Future<bool> purchasePremium() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // We typically assume the first package is the monthly one for this jam
        final package = offerings.current!.availablePackages.first;
        
        CustomerInfo customerInfo = await Purchases.purchasePackage(package);
        return customerInfo.entitlements.all['premium']?.isActive ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error purchasing premium: $e');
      return false;
    }
  }
}
*/

// Temporary stub for RevenueCat service
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  /// Initialize RevenueCat with the Firebase User ID
  Future<void> init(String userId) async {
    if (_isInitialized) return;

    // For now, just mark as initialized without actual RevenueCat setup
    _isInitialized = true;
    print('✅ RevenueCat stub initialized for User ID: $userId');
  }

  Future<bool> isPremiumUser() async {
    return false; // Always return false for now
  }

  Future<bool> purchasePremium() async {
    return false; // Always return false for now
  }
}
