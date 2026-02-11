import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/extraction_result.dart';
import '../utils/content_hasher.dart';
import 'extraction_cache_service.dart';
import 'extraction_retry_service.dart';
import 'extraction_cache_service.dart';
import 'extraction_retry_service.dart';
import 'recipe_ai_service.dart';
import 'api_throttle_service.dart'; // Import

/// Robust Recipe Extraction Service with Multi-Layer Caching and Retry Logic
/// Cache hierarchy: Hive (local) -> Firestore (cloud) -> Fresh AI extraction
class RecipeExtractionService {
  // Singleton pattern
  static final RecipeExtractionService _instance = RecipeExtractionService._internal();
  factory RecipeExtractionService() => _instance;
  RecipeExtractionService._internal();

  final ExtractionCacheService _cacheService = ExtractionCacheService();
  final RecipeAiService _aiService = RecipeAiService();
  bool _isInitialized = false;

  /// Initialize the extraction service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _cacheService.initialize();
      _isInitialized = true;
      debugPrint("✅ Recipe extraction service initialized");
    } catch (e) {
      debugPrint("⚠️ Failed to initialize extraction service: $e");
    }
  }

  /// Extract recipe with robust caching and retry logic
  /// [pdfPath] is the absolute path to the local PDF file
  /// [onProgress] callback for UI updates
  Future<ExtractionResult> extractRecipe({
    String? url, 
    String? pdfPath,
    Function(String)? onProgress,
  }) async {
    await initialize();
    
    try {
      // Generate content hash for caching
      String contentHash;
      String sourceInfo;
      
      if (pdfPath != null) {
        onProgress?.call('Analyzing PDF file...');
        final file = File(pdfPath);
        contentHash = await ContentHasher.hashFile(file);
        sourceInfo = 'PDF: ${file.path.split('/').last}';
      } else if (url != null) {
        onProgress?.call('Processing URL...');
        contentHash = ContentHasher.hashUrl(url);
        sourceInfo = 'URL: $url';
      } else {
        throw Exception('Either PDF path or URL must be provided');
      }

      debugPrint("🔐 Content hash: $contentHash");

      // 1. Check cache first
      onProgress?.call('Checking cache...');
      final cachedResult = await _cacheService.getCached(contentHash);
      if (cachedResult != null) {
        onProgress?.call('Found in cache! Loading recipes...');
        return cachedResult;
      }

      // 2. Fresh extraction with retry logic
      if (pdfPath != null) {
        return await _extractFromPdf(pdfPath, contentHash, sourceInfo, onProgress);
      } else {
        return await _extractFromUrl(url!, contentHash, sourceInfo, onProgress);
      }

    } catch (e) {
      debugPrint("❌ Extraction failed: $e");
      
      // Return user-friendly error wrapped in result
      return ExtractionResult.fresh(
        recipes: [],
        totalChunksProcessed: 0,
        sourceInfo: pdfPath ?? url,
        warnings: [ExtractionRetryService.getFriendlyErrorMessage(e, 1)],
      );
    }
  }

  /// Extract from PDF with robust processing
  Future<ExtractionResult> _extractFromPdf(
    String pdfPath, 
    String contentHash, 
    String sourceInfo,
    Function(String)? onProgress,
  ) async {
    final retryConfig = ExtractionRetryService.getRetryConfig('pdf');
    
    return await ExtractionRetryService.withRetry<ExtractionResult>(
      () async => _tryExtractFromPdf(pdfPath, contentHash, sourceInfo, onProgress),
      maxRetries: retryConfig['maxRetries'],
      baseDelay: retryConfig['baseDelay'],
      shouldRetry: ExtractionRetryService.isRetryableError,
      onRetry: (attempt, error, nextDelay) {
        onProgress?.call('Retrying extraction (attempt $attempt)...');
        debugPrint("🔄 PDF extraction retry $attempt: $error");
      },
    );
  }

  /// Try PDF extraction (single attempt)
  Future<ExtractionResult> _tryExtractFromPdf(
    String pdfPath,
    String contentHash,
    String sourceInfo,
    Function(String)? onProgress,
  ) async {
    onProgress?.call('Reading PDF content...');
    
    // Extract text from PDF
    final text = await ReadPdfText.getPDFtext(pdfPath).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('PDF reading timed out. File might be too large or corrupted.'),
    );
    
    if (text.trim().isEmpty) {
      throw Exception('No text found in PDF. It might be an image scan.');
    }
    
    if (text.length < 50) {
      throw Exception('PDF text is too short. Make sure the PDF contains recipe content.');
    }
    
    debugPrint("📄 Extracted ${text.length} characters from PDF");

    // Process with AI
    return await _processTextWithAI(text, contentHash, sourceInfo, onProgress);
  }

  /// Extract from URL (fallback to mock for demo)
  Future<ExtractionResult> _extractFromUrl(
    String url,
    String contentHash,
    String sourceInfo,
    Function(String)? onProgress,
  ) async {
    onProgress?.call('Processing URL...');
    
    // For demo purposes, use the existing mock logic
    await Future.delayed(const Duration(seconds: 2));
    
    final inputString = url.toLowerCase();
    Recipe? mockRecipe;
    
    if (inputString.contains('pasta') || inputString.contains('spaghetti') || inputString.contains('italian')) {
      mockRecipe = _getRecipeData(_pastaRecipe, url);
    } else if (inputString.contains('chicken') || inputString.contains('curry') || inputString.contains('roast')) {
      mockRecipe = _getRecipeData(_chickenRecipe, url);
    } else if (inputString.contains('salad') || inputString.contains('healthy') || inputString.contains('vegan')) {
      mockRecipe = _getRecipeData(_saladRecipe, url);
    } else if (inputString.contains('cake') || inputString.contains('dessert') || inputString.contains('sweet')) {
      mockRecipe = _getRecipeData(_cakeRecipe, url);
    } else {
      mockRecipe = _getRecipeData(_defaultRecipe, url);
    }

    final result = ExtractionResult.fresh(
      recipes: [mockRecipe],
      totalChunksProcessed: 1,
      sourceInfo: sourceInfo,
    );

    // Cache the result
    await _cacheService.saveToCache(contentHash, result, sourceInfo: sourceInfo);
    
    return result;
  }

  /// Process text with AI extraction and chunking
  Future<ExtractionResult> _processTextWithAI(
    String text,
    String contentHash,
    String sourceInfo,
    Function(String)? onProgress,
  ) async {
    // Split into chunks with overlap for better recipe capture
    final chunks = _splitTextIntoChunks(text, 2000, overlap: 500);
    onProgress?.call('Processing ${chunks.length} sections...');
    
    List<Recipe> allRecipes = [];
    List<String> warnings = [];
    int successfulChunks = 0;

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      onProgress?.call('Analyzing section ${i + 1} of ${chunks.length}...');
      
      try {
        // Throttle AI calls to prevent rate limits
        await ApiThrottleService.throttle('gemini_extraction');

        final recipes = await _aiService.analyzeText(chunk).timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            warnings.add('Section ${i + 1} timed out - skipped');
            return <Recipe>[];
          },
        );
        
        allRecipes.addAll(recipes);
        successfulChunks++;
        
        if (recipes.isNotEmpty) {
          onProgress?.call('Found ${recipes.length} recipe${recipes.length == 1 ? '' : 's'} in section ${i + 1}');
        }
        
      } catch (e) {
        debugPrint("⚠️ Failed to process chunk ${i + 1}: $e");
        warnings.add('Section ${i + 1} failed: ${e.toString()}');
      }
    }

    // Deduplicate recipes
    final uniqueRecipes = _deduplicateRecipes(allRecipes);
    
    if (uniqueRecipes.isEmpty && warnings.isEmpty) {
      throw Exception('No recipes found in the document. The content might not contain recipe information.');
    }

    final result = uniqueRecipes.isNotEmpty
        ? ExtractionResult.fresh(
            recipes: uniqueRecipes,
            totalChunksProcessed: chunks.length,
            sourceInfo: sourceInfo,
            warnings: warnings,
          )
        : ExtractionResult.partialSuccess(
            recipes: [],
            totalChunksProcessed: chunks.length,
            sourceInfo: sourceInfo,
            warnings: warnings.isEmpty 
                ? ['No recipes could be extracted from the document']
                : warnings,
          );

    // Cache successful results
    if (uniqueRecipes.isNotEmpty) {
      await _cacheService.saveToCache(contentHash, result, sourceInfo: sourceInfo);
    }

    return result;
  }

  /// Split text into overlapped chunks
  List<String> _splitTextIntoChunks(String text, int chunkSize, {int overlap = 0}) {
    List<String> chunks = [];
    int start = 0;
    
    while (start < text.length) {
      int end = start + chunkSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      
      // Try to break at a newline to avoid cutting sentences/recipes
      int lastNewline = text.lastIndexOf('\n', end);
      if (lastNewline != -1 && lastNewline > start + overlap) {
        end = lastNewline;
      }
      
      chunks.add(text.substring(start, end));
      
      // Move start forward, but minus overlap to capture context
      start = end - overlap;
      
      // Safety check: ensure we advance
      if (start >= end) start = end;
    }
    
    return chunks;
  }
  
  /// Deduplicate recipes based on title similarity
  List<Recipe> _deduplicateRecipes(List<Recipe> recipes) {
    final Map<String, Recipe> unique = {};
    
    for (var recipe in recipes) {
      final key = recipe.title.trim().toLowerCase();
      
      if (!unique.containsKey(key)) {
        unique[key] = recipe;
      } else {
        // Keep the one with more detailed instructions
        if ((recipe.instructions?.length ?? 0) > (unique[key]?.instructions?.length ?? 0)) {
          unique[key] = recipe;
        }
      }
    }
    
    return unique.values.toList();
  }

  /// Get cache statistics for debugging
  Future<Map<String, dynamic>> getCacheStats() async {
    await initialize();
    return await _cacheService.getCacheStats();
  }

  /// Clear all caches (for testing/debugging)
  Future<void> clearCaches() async {
    await initialize();
    await _cacheService.clearAllCaches();
  }

  /// Helper to convert Map data to Recipe model (Legacy Mock)
  Recipe _getRecipeData(Map<String, dynamic> data, String? source) {
    List<Ingredient> ingredients = [];
    if (data['ingredients'] != null) {
      for (var item in data['ingredients']) {
        ingredients.add(Ingredient(
          id: DateTime.now().millisecondsSinceEpoch.toString() + item['name'],
          name: item['name'],
          quantity: '1', // FIXED: Must be a String, not int
          unit: item['amount'] ?? '', 
          category: item['category'] ?? 'Uncategorized',
        ));
      }
    }

    // FIXED: Instructions must be a single String (joined by newlines), not a List
    String instructionsText = '';
    if (data['instructions'] != null && data['instructions'] is List) {
      instructionsText = (data['instructions'] as List).join('\n\n');
    }

    // Determine source type
    String sourceType = 'manual';
    if (source != null && (source.contains('http') || source.contains('www'))) {
      sourceType = 'video';
    }

    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Untitled Recipe',
      description: data['description'] ?? '',
      source: sourceType,
      sourceUrl: source,
      ingredients: ingredients.map((i) => i.name).toList(), 
      instructions: instructionsText, // FIXED: Passing String, not List
      isPremium: true,
      imageUrl: 'assets/images/placeholder_food.png',
      cookCount: 0,
      tags: ['Extracted', 'Demo'],
    );
  }

  // ==========================================
  // LOCAL MOCK DATA LIBRARY (Matches Backend)
  // ==========================================

  final Map<String, dynamic> _pastaRecipe = {
    "title": "Creamy Tomato & Basil Pasta",
    "description": "A rich, velvety tomato sauce clinging to perfectly cooked pasta, finished with fresh fragrant basil.",
    "ingredients": [
      {"name": "Penne Pasta", "amount": "500g", "category": "Pantry"},
      {"name": "Tomato Puree", "amount": "400g", "category": "Pantry"},
      {"name": "Heavy Cream", "amount": "200ml", "category": "Dairy"},
      {"name": "Garlic", "amount": "3 cloves", "category": "Produce"},
      {"name": "Fresh Basil", "amount": "1 bunch", "category": "Produce"},
      {"name": "Parmesan Cheese", "amount": "50g", "category": "Dairy"}
    ],
    "instructions": [
      "Bring a large pot of salted water to a boil and cook pasta until al dente.",
      "In a saucepan, sauté minced garlic in olive oil until fragrant.",
      "Add tomato puree and simmer for 10 minutes on low heat.",
      "Stir in the heavy cream and half the parmesan. Season with salt and pepper.",
      "Toss the cooked pasta with the sauce.",
      "Serve hot, garnished with fresh basil leaves and remaining parmesan."
    ]
  };

  final Map<String, dynamic> _chickenRecipe = {
    "title": "Classic Butter Chicken",
    "description": "Tender chicken pieces simmered in a creamy, spiced tomato curry sauce. A crowd favorite.",
    "ingredients": [
      {"name": "Chicken Breast", "amount": "500g", "category": "Meat"},
      {"name": "Butter", "amount": "50g", "category": "Dairy"},
      {"name": "Tomato Paste", "amount": "2 tbsp", "category": "Pantry"},
      {"name": "Garam Masala", "amount": "2 tsp", "category": "Pantry"},
      {"name": "Heavy Cream", "amount": "1 cup", "category": "Dairy"},
      {"name": "Ginger Garlic Paste", "amount": "1 tbsp", "category": "Pantry"}
    ],
    "instructions": [
      "Marinate chicken cubes with ginger garlic paste and salt for 30 mins.",
      "Pan-fry the chicken in butter until golden brown.",
      "Add tomato paste, garam masala, and cream. Simmer for 15 minutes.",
      "Finish with a knob of butter and serve with naan or rice."
    ]
  };

  final Map<String, dynamic> _saladRecipe = {
    "title": "Mediterranean Quinoa Salad",
    "description": "A refreshing, nutrient-packed salad with quinoa, crisp vegetables, and a zesty lemon dressing.",
    "ingredients": [
      {"name": "Quinoa", "amount": "1 cup", "category": "Pantry"},
      {"name": "Cucumber", "amount": "1 medium", "category": "Produce"},
      {"name": "Cherry Tomatoes", "amount": "1 cup", "category": "Produce"},
      {"name": "Feta Cheese", "amount": "100g", "category": "Dairy"},
      {"name": "Olives", "amount": "1/2 cup", "category": "Pantry"},
      {"name": "Lemon Juice", "amount": "2 tbsp", "category": "Pantry"}
    ],
    "instructions": [
      "Rinse quinoa and cook in water according to package instructions. Let cool.",
      "Dice cucumber and halve the cherry tomatoes.",
      "In a large bowl, combine quinoa, veggies, olives, and crumbled feta.",
      "Drizzle with olive oil and lemon juice. Toss gently to combine."
    ]
  };

  final Map<String, dynamic> _cakeRecipe = {
    "title": "Molten Chocolate Lava Cake",
    "description": "Decadent individual chocolate cakes with a gooey, flowing center.",
    "ingredients": [
      {"name": "Dark Chocolate", "amount": "100g", "category": "Pantry"},
      {"name": "Butter", "amount": "100g", "category": "Dairy"},
      {"name": "Eggs", "amount": "2", "category": "Dairy"},
      {"name": "Sugar", "amount": "1/2 cup", "category": "Pantry"},
      {"name": "Flour", "amount": "2 tbsp", "category": "Pantry"}
    ],
    "instructions": [
      "Preheat oven to 200°C (400°F). Grease ramekins.",
      "Melt chocolate and butter together.",
      "Whisk eggs and sugar until pale, then fold into the chocolate mix.",
      "Sift in flour and fold gently.",
      "Pour into ramekins and bake for 12-14 minutes. Center should still be wobbly."
    ]
  };

  final Map<String, dynamic> _defaultRecipe = {
    "title": "Chef's Special: Grilled Salmon",
    "description": "Perfectly grilled salmon fillet with a lemon butter glaze and roasted asparagus.",
    "ingredients": [
      {"name": "Salmon Fillet", "amount": "2 pieces", "category": "Meat"},
      {"name": "Asparagus", "amount": "1 bunch", "category": "Produce"},
      {"name": "Butter", "amount": "3 tbsp", "category": "Dairy"},
      {"name": "Lemon", "amount": "1", "category": "Produce"},
      {"name": "Garlic Powder", "amount": "1 tsp", "category": "Pantry"}
    ],
    "instructions": [
      "Season salmon with salt, pepper, and garlic powder.",
      "Grill salmon for 4-5 minutes per side.",
      "In a small pan, melt butter with lemon juice.",
      "Roast asparagus in the oven with olive oil for 10 minutes.",
      "Pour lemon butter over salmon and serve with asparagus."
    ]
  };
}
