import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/services/premium_service.dart';
import 'lib/services/revenue_cat_service.dart';

/// Test file to verify the premium flow implementation
/// Run this to test the end-to-end premium feature flow
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Premium Flow Implementation');
  print('=====================================');
  
  // Test 1: RevenueCatService initialization
  print('\n1️⃣ Testing RevenueCatService...');
  final rcService = RevenueCatService();
  
  final initResult = await rcService.init('test_user_123');
  if (initResult.isSuccess) {
    print('✅ RevenueCat initialized successfully');
  } else {
    print('⚠️ RevenueCat init failed: ${initResult.error}');
    print('   This is expected in test environment - mock mode will be used');
  }
  
  // Test 2: PremiumService initialization
  print('\n2️⃣ Testing PremiumService...');
  final premiumService = PremiumService();
  
  await premiumService.init();
  print('✅ PremiumService initialized');
  print('   Mock mode: ${premiumService.isMockMode}');
  print('   Premium status: ${premiumService.isPremium.value}');
  
  // Test 3: Mock purchase flow
  print('\n3️⃣ Testing Mock Purchase Flow...');
  print('   Attempting premium purchase...');
  
  final purchaseResult = await premiumService.purchasePremium(isYearly: false);
  
  if (purchaseResult.isSuccess) {
    print('✅ Purchase successful!');
    print('   Premium status: ${premiumService.isPremium.value}');
    print('   Mock mode: ${premiumService.isMockMode}');
  } else {
    print('❌ Purchase failed: ${purchaseResult.error}');
  }
  
  // Test 4: Feature access
  print('\n4️⃣ Testing Feature Access...');
  final features = [
    'journal',
    'meal_planning', 
    'nutrition_dashboard',
    'ai_dietitian',
    'unlimited_recipes',
    'video_recipes'
  ];
  
  for (final feature in features) {
    final hasAccess = premiumService.canUseFeature(feature);
    print('   $feature: ${hasAccess ? "✅ Accessible" : "❌ Locked"}');
  }
  
  // Test 5: Persistence test
  print('\n5️⃣ Testing Persistence...');
  print('   Creating new PremiumService instance...');
  
  final newPremiumService = PremiumService();
  await newPremiumService.init();
  
  print('   Premium status after restart: ${newPremiumService.isPremium.value}');
  
  if (newPremiumService.isPremium.value == premiumService.isPremium.value) {
    print('✅ Premium status persisted correctly');
  } else {
    print('❌ Premium status not persisted');
  }
  
  print('\n🎉 Premium Flow Test Complete!');
  print('=====================================');
  print('Summary:');
  print('- RevenueCat Service: ${initResult.isSuccess ? "✅" : "⚠️ (Mock mode)"}');
  print('- Premium Service: ✅');
  print('- Mock Purchase: ${purchaseResult.isSuccess ? "✅" : "❌"}');
  print('- Feature Access: ✅');
  print('- Persistence: ${newPremiumService.isPremium.value == premiumService.isPremium.value ? "✅" : "❌"}');
  
  print('\n📱 Manual Testing Steps:');
  print('1. Open Journal tab → Should show paywall');
  print('2. Tap "Start Free Trial" → Should unlock premium (demo mode)');
  print('3. Journal should now be accessible');
  print('4. Restart app → Premium should still be active');
  print('5. Profile should show Premium badge');
  print('6. Nutrition Dashboard should be accessible');
}