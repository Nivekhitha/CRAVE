import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class UnsplashImageService {
  static const String _baseUrl = 'https://api.unsplash.com';
  
  // Singleton pattern
  static final UnsplashImageService _instance = UnsplashImageService._internal();
  factory UnsplashImageService() => _instance;
  UnsplashImageService._internal();

  // In-memory cache to avoid repeated API calls
  final Map<String, String> _imageCache = {};
  
  // Rotating fallback images
  final List<String> _fallbacks = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800', // Food 1
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800', // Food 2 (Salad)
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800', // Food 3 (Vegetables)
    'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=800', // Food 4 (Breakfast)
  ];

  Future<String> getRecipeImage(String recipeName, {List<String>? tags}) async {
    // Check cache first
    final cacheKey = '$recipeName${tags?.join('')}';
    if (_imageCache.containsKey(cacheKey)) {
      debugPrint('📸 Unsplash Cache Hit: $recipeName');
      return _imageCache[cacheKey]!;
    }

    try {
      final accessKey = dotenv.env['UNSPLASH_ACCESS_KEY'];
      if (accessKey == null || accessKey == 'YOUR_KEY_HERE' || accessKey.isEmpty) {
        debugPrint('⚠️ Unsplash API Key missing or invalid. Using fallback.');
        return _getFallbackImage();
      }

      // Try multiple search strategies for best results
      String? imageUrl;
      
      // Strategy 1: Recipe name + main tag + "food"
      if (imageUrl == null && tags != null && tags.isNotEmpty) {
        final mainTag = tags.first;
        imageUrl = await _searchUnsplash('$recipeName $mainTag food', accessKey);
      }
      
      // Strategy 2: Just recipe name + "food"
      if (imageUrl == null) {
        final searchTerm = _extractSearchTerm(recipeName);
        imageUrl = await _searchUnsplash('$searchTerm food', accessKey);
      }
      
      // Strategy 3: Generic food category from tags
      if (imageUrl == null && tags != null && tags.isNotEmpty) {
        imageUrl = await _searchUnsplash('${tags.first} food dish', accessKey);
      }
      
      // Cache and return if found
      if (imageUrl != null) {
        _imageCache[cacheKey] = imageUrl;
        return imageUrl;
      }
      
      // Fallback if all strategies fail
      debugPrint('⚠️ All Unsplash search strategies failed for: $recipeName');
      return _getFallbackImage();
    } catch (e) {
      debugPrint('❌ Unsplash Exception: $e');
      return _getFallbackImage();
    }
  }
  
  Future<String?> _searchUnsplash(String query, String accessKey) async {
    try {
      debugPrint('🔍 Unsplash Search: "$query"');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/search/photos?query=${Uri.encodeComponent(query)}&orientation=landscape&per_page=1'),
        headers: {
          'Authorization': 'Client-ID $accessKey',
          'Accept-Version': 'v1',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          final imageUrl = data['results'][0]['urls']['regular'];
          debugPrint('✅ Found image for: $query');
          return imageUrl;
        }
      } else if (response.statusCode == 403) {
        debugPrint('⚠️ Unsplash API rate limit exceeded');
      }
      
      return null;
    } catch (e) {
      debugPrint('⚠️ Unsplash search failed for "$query": $e');
      return null;
    }
  }
  
  String _extractSearchTerm(String recipeName) {
    // "Chicken Curry" → "chicken curry"
    // "Mom's Special Pasta" → "pasta"
    final cleaned = recipeName.toLowerCase()
      .replaceAll(RegExp(r"'s|mom's|grandma's|special|homemade|best|quick|easy|delicious"), '')
      .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special chars
      .trim();
    
    // Take first 2-3 significant words
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.length > 2).take(3).join(' ');
    
    return Uri.encodeComponent(words.isEmpty ? 'delicious food' : words);
  }
  
  String _getFallbackImage() {
    // Return a random fallback from the list
    return _fallbacks[Random().nextInt(_fallbacks.length)];
  }
}
