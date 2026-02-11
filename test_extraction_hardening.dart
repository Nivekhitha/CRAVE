import 'package:flutter/material.dart';
import 'lib/services/recipe_extraction_service.dart';
import 'lib/services/extraction_cache_service.dart';
import 'lib/services/extraction_retry_service.dart';
import 'lib/utils/content_hasher.dart';

/// Test file for the new robust extraction system
/// Run with: flutter run test_extraction_hardening.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🧪 Testing Extraction Hardening Implementation");
  print("=" * 50);
  
  // Test 1: Content Hasher
  await testContentHasher();
  
  // Test 2: Cache Service
  await testCacheService();
  
  // Test 3: Retry Service
  await testRetryService();
  
  // Test 4: Extraction Service
  await testExtractionService();
  
  print("\n✅ All tests completed!");
}

Future<void> testContentHasher() async {
  print("\n📝 Testing Content Hasher...");
  
  final hash1 = ContentHasher.hashString("Hello World");
  final hash2 = ContentHasher.hashString("Hello World");
  final hash3 = ContentHasher.hashString("Different Content");
  
  assert(hash1 == hash2, "Same content should produce same hash");
  assert(hash1 != hash3, "Different content should produce different hash");
  assert(hash1.length == 64, "SHA256 hash should be 64 characters");
  
  final urlHash = ContentHasher.hashUrl("https://example.com/recipe?param=1#section");
  print("  ✓ URL hash: ${urlHash.substring(0, 8)}...");
  
  print("  ✅ Content Hasher tests passed");
}

Future<void> testCacheService() async {
  print("\n💾 Testing Cache Service...");
  
  try {
    final cacheService = ExtractionCacheService();
    await cacheService.initialize();
    
    // Test cache miss
    final result = await cacheService.getCached("nonexistent_hash");
    assert(result == null, "Cache miss should return null");
    
    print("  ✓ Cache initialization successful");
    print("  ✓ Cache miss handling works");
    print("  ✅ Cache Service tests passed");
  } catch (e) {
    print("  ⚠️ Cache Service test failed: $e");
  }
}

Future<void> testRetryService() async {
  print("\n🔄 Testing Retry Service...");
  
  // Test successful operation (no retries needed)
  int attempts = 0;
  final result = await ExtractionRetryService.withRetry<String>(
    () async {
      attempts++;
      return "Success on attempt $attempts";
    },
    maxRetries: 3,
  );
  
  assert(attempts == 1, "Successful operation should only run once");
  assert(result == "Success on attempt 1", "Should return correct result");
  
  // Test retry logic
  attempts = 0;
  try {
    await ExtractionRetryService.withRetry<String>(
      () async {
        attempts++;
        if (attempts < 3) {
          throw Exception("Temporary failure");
        }
        return "Success after retries";
      },
      maxRetries: 3,
      baseDelay: Duration(milliseconds: 10), // Fast for testing
    );
  } catch (e) {
    // Expected to succeed after retries
  }
  
  assert(attempts == 3, "Should retry until success");
  
  // Test error classification
  assert(ExtractionRetryService.isRetryableError("Network timeout"), "Network errors should be retryable");
  assert(!ExtractionRetryService.isRetryableError("Invalid API key"), "Auth errors should not be retryable");
  
  print("  ✓ Retry logic works correctly");
  print("  ✓ Error classification works");
  print("  ✅ Retry Service tests passed");
}

Future<void> testExtractionService() async {
  print("\n🤖 Testing Extraction Service...");
  
  try {
    final extractionService = RecipeExtractionService();
    await extractionService.initialize();
    
    // Test URL extraction (mock mode)
    print("  Testing URL extraction...");
    final result = await extractionService.extractRecipe(
      url: "https://example.com/pasta-recipe",
      onProgress: (step) => print("    Progress: $step"),
    );
    
    assert(result.hasRecipes, "Should find recipes in mock mode");
    assert(result.recipes.first.title.contains("Pasta"), "Should return pasta recipe for pasta URL");
    
    print("  ✓ URL extraction works");
    print("  ✓ Progress callbacks work");
    print("  ✓ Mock recipe selection works");
    
    // Test cache stats
    final stats = await extractionService.getCacheStats();
    print("  ✓ Cache stats: $stats");
    
    print("  ✅ Extraction Service tests passed");
  } catch (e) {
    print("  ⚠️ Extraction Service test failed: $e");
  }
}