import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/recipe.dart';
import 'auth_service.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _auth = AuthService();
  
  // Singleton
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // Image sources priority order
  static const List<RecipeImageSource> _imageSources = [
    RecipeImageSource.userUploaded,    // Highest priority
    RecipeImageSource.aiGenerated,     // AI-generated images
    RecipeImageSource.unsplash,        // Free stock photos
    RecipeImageSource.placeholder,     // Fallback
  ];

  /// Get the best available image URL for a recipe
  Future<String?> getRecipeImageUrl(Recipe recipe) async {
    try {
      // 1. Check if user uploaded an image
      if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
        if (await _isValidImageUrl(recipe.imageUrl!)) {
          return recipe.imageUrl!;
        }
      }

      // 2. Check for cached AI-generated image
      final aiImageUrl = await _getAIGeneratedImage(recipe);
      if (aiImageUrl != null) {
        return aiImageUrl;
      }

      // 3. Get Unsplash image based on recipe title
      final unsplashUrl = _getUnsplashImageUrl(recipe.title, recipe.id);
      if (await _isValidImageUrl(unsplashUrl)) {
        return unsplashUrl;
      }

      // 4. Fallback (now returns null)
      return _getPlaceholderImageUrl(recipe);
    } catch (e) {
      debugPrint('❌ Error getting recipe image URL: $e');
      return _getPlaceholderImageUrl(recipe);
    }
  }
  
  // Future<String?> _getAIGeneratedImage(Recipe recipe) ... (assuming this signature is already compatible or needs check. 
  // Since I can't see it, I'll assume it returns String? based on usage `if (aiImageUrl != null)`).
  
  // _getUnsplashImageUrl returns String (non-future usually). I'll check its usage.
  
  // ...

  // Fix getOptimizedImageUrl
  String? getOptimizedImageUrl(String? originalUrl, ImageSize size) {
    if (originalUrl == null) return null;

    if (originalUrl.contains('loremflickr.com')) {
      final dimensions = _getDimensionsForSize(size);
      return originalUrl.replaceAll(
        RegExp(r'/\d+/\d+/'),
        '/${dimensions.width}/${dimensions.height}/',
      );
    } else if (originalUrl.contains('source.unsplash.com')) {
      final dimensions = _getDimensionsForSize(size);
      return originalUrl.replaceAll(
        RegExp(r'/\d+x\d+/'),
        '/${dimensions.width}x${dimensions.height}/',
      );
    }
    
    return originalUrl;
  }

  /// Upload user image to Firebase Storage
  Future<String> uploadUserImage(File imageFile, String recipeId) async {
    try {
      final userId = _auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      // Compress image before upload
      final compressedImage = await _compressImage(imageFile);
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recipe_${recipeId}_$timestamp.jpg';
      
      // Upload to Firebase Storage
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('recipes')
          .child(fileName);

      final uploadTask = ref.putData(compressedImage);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;

    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow;
    }
  }

  /// Generate AI image using recipe title and ingredients
  Future<String?> _getAIGeneratedImage(Recipe recipe) async {
    try {
      // Check cache first
      final cacheKey = _generateImageCacheKey(recipe);
      final cachedUrl = await _getCachedImageUrl(cacheKey);
      if (cachedUrl != null) {
        return cachedUrl;
      }

      // For MVP, we'll use a deterministic approach with Unsplash
      // In production, you could integrate with DALL-E, Midjourney, or Stable Diffusion
      final aiPrompt = _generateImagePrompt(recipe);
      final generatedUrl = await _generateImageWithUnsplash(aiPrompt);
      
      if (generatedUrl != null) {
        await _cacheImageUrl(cacheKey, generatedUrl);
        return generatedUrl;
      }

      return null;
    } catch (e) {
      debugPrint('⚠️ AI image generation failed: $e');
      return null;
    }
  }

  /// Get Unsplash image URL based on recipe title
  String _getUnsplashImageUrl(String recipeTitle, [String? recipeId]) {
    // Clean and format recipe title for search
    final searchTerm = recipeTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(' ', ',');
    
    // LoremFlickr (free alternative to Unsplash Source)
    // Use recipeId hash as lock to ensure consistent image for same recipe
    final lock = recipeId != null ? recipeId.hashCode : DateTime.now().millisecondsSinceEpoch;
    return 'https://loremflickr.com/800/600/food,$searchTerm?lock=$lock';
  }

  /// Generate placeholder image URL
  /// Returns null so SmartRecipeImage can show its gradient fallback
  String? _getPlaceholderImageUrl(Recipe recipe) {
    return null; 
  }

  /// Get a consistent avatar URL for the user
  String getUserAvatarUrl(String? seed) {
    // Use a consistent robot/avatar service or just return asset path logic in UI
    // specific to avatars.
    // For now, let's use a nice Unsplash collection or UI Avatars?
    // UI Avatars is clean:
    final name = seed ?? 'User';
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&color=fff';
  }

  /// Compress image for efficient storage and loading
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      // Read original image
      final originalBytes = await imageFile.readAsBytes();
      
      // For MVP, we'll just resize if too large
      // In production, use image compression packages like flutter_image_compress
      if (originalBytes.length > 1024 * 1024) { // 1MB
        debugPrint('🗜️ Image needs compression: ${originalBytes.length} bytes');
        // TODO: Implement actual compression
        return originalBytes;
      }
      
      return originalBytes;
    } catch (e) {
      debugPrint('❌ Error compressing image: $e');
      rethrow;
    }
  }

  /// Check if image URL is valid and accessible
  Future<bool> _isValidImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 3), // Reduced timeout for better UX
      );
      // 302 Found is also acceptable as it usually redirects to the actual image
      return (response.statusCode == 200 || response.statusCode == 302);
    } catch (e) {
      debugPrint('⚠️ Image URL validation failed for $url: $e');
      return false;
    }
  }

  /// Generate image prompt for AI generation
  String _generateImagePrompt(Recipe recipe) {
    final ingredients = recipe.ingredients.take(3).join(', ');
    final style = recipe.tags?.contains('Healthy') == true ? 'fresh, vibrant' : 'appetizing, delicious';
    
    return 'A $style photo of ${recipe.title} made with $ingredients, professional food photography, well-lit, appetizing presentation';
  }

  /// Generate cache key for image
  String _generateImageCacheKey(Recipe recipe) {
    final content = '${recipe.title}_${recipe.ingredients.join('_')}';
    final bytes = convert.utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cache image URL locally
  Future<void> _cacheImageUrl(String key, String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheFile = File('${directory.path}/image_cache_$key.txt');
      await cacheFile.writeAsString(url);
    } catch (e) {
      debugPrint('⚠️ Failed to cache image URL: $e');
    }
  }

  /// Get cached image URL
  Future<String?> _getCachedImageUrl(String key) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheFile = File('${directory.path}/image_cache_$key.txt');
      
      if (await cacheFile.exists()) {
        final url = await cacheFile.readAsString();
        // Check if cached URL is still valid
        if (await _isValidImageUrl(url)) {
          return url;
        } else {
          // Remove invalid cached URL
          await cacheFile.delete();
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('⚠️ Failed to get cached image URL: $e');
      return null;
    }
  }

  /// Generate image using Unsplash with specific search terms
  Future<String?> _generateImageWithUnsplash(String prompt) async {
    try {
      // Extract key terms from AI prompt
      final keyTerms = _extractKeyTermsFromPrompt(prompt);
      final searchQuery = keyTerms.join(',');
      
      // Use LoremFlickr with specific terms
      final url = 'https://loremflickr.com/800/600/$searchQuery';
      
      if (await _isValidImageUrl(url)) {
        return url;
      }
      
      return null;
    } catch (e) {
      debugPrint('⚠️ Unsplash image generation failed: $e');
      return null;
    }
  }

  /// Extract key terms from AI prompt for image search
  List<String> _extractKeyTermsFromPrompt(String prompt) {
    final commonWords = {'a', 'an', 'the', 'of', 'with', 'made', 'photo', 'professional', 'well-lit'};
    
    return prompt
        .toLowerCase()
        .split(RegExp(r'[,\s]+'))
        .where((word) => word.length > 2 && !commonWords.contains(word))
        .take(5)
        .toList();
  }

  /// Get color code for category (for placeholders)
  String _getColorCodeForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast': return 'FFE135';
      case 'lunch': return '4CAF50';
      case 'dinner': return 'FF5722';
      case 'dessert': return 'E91E63';
      case 'healthy': return '8BC34A';
      case 'comfort': return 'FF9800';
      default: return '2196F3';
    }
  }

  /// Delete user uploaded image
  Future<void> deleteUserImage(String imageUrl) async {
    try {
      if (imageUrl.contains('firebase')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        debugPrint('✅ Image deleted successfully');
      }
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
    }
  }



  /// Get dimensions for image size
  ImageDimensions _getDimensionsForSize(ImageSize size) {
    switch (size) {
      case ImageSize.thumbnail:
        return const ImageDimensions(150, 150);
      case ImageSize.card:
        return const ImageDimensions(300, 200);
      case ImageSize.detail:
        return const ImageDimensions(800, 600);
      case ImageSize.fullscreen:
        return const ImageDimensions(1200, 900);
    }
  }

  /// Preload images for better UX
  Future<void> preloadRecipeImages(List<Recipe> recipes, BuildContext context) async {
    for (final recipe in recipes.take(5)) { // Preload first 5
      try {
        final imageUrl = await getRecipeImageUrl(recipe);
        if (imageUrl != null) {
          // Preload using cached_network_image
          await precacheImage(CachedNetworkImageProvider(imageUrl), context);
        }
      } catch (e) {
        debugPrint('⚠️ Failed to preload image for ${recipe.title}: $e');
      }
    }
  }

  /// Clear image cache
  Future<void> clearImageCache() async {
    try {
      await CachedNetworkImage.evictFromCache('');
      
      // Clear local cache files
      final directory = await getApplicationDocumentsDirectory();
      final cacheFiles = directory.listSync()
          .where((file) => file.path.contains('image_cache_'));
      
      for (final file in cacheFiles) {
        await file.delete();
      }
      
      debugPrint('✅ Image cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing image cache: $e');
    }
  }
}

// Enums and classes for image management
enum RecipeImageSource {
  userUploaded,
  aiGenerated,
  unsplash,
  placeholder,
}

enum ImageSize {
  thumbnail,
  card,
  detail,
  fullscreen,
}

// Image dimensions helper class
class ImageDimensions {
  final int width;
  final int height;
  
  const ImageDimensions(this.width, this.height);
}