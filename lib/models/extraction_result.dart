import 'recipe.dart';

/// Represents the result of a recipe extraction operation
class ExtractionResult {
  final List<Recipe> recipes;
  final bool isFromCache;
  final String? cacheSource; // 'hive', 'firestore', or null for fresh
  final DateTime extractedAt;
  final String? sourceInfo;
  final int totalChunksProcessed;
  final List<String> warnings;

  const ExtractionResult({
    required this.recipes,
    this.isFromCache = false,
    this.cacheSource,
    required this.extractedAt,
    this.sourceInfo,
    this.totalChunksProcessed = 0,
    this.warnings = const [],
  });

  /// Create result from cache
  ExtractionResult.fromCache({
    required this.recipes,
    required this.cacheSource,
    required this.extractedAt,
    this.sourceInfo,
    this.warnings = const [],
  }) : isFromCache = true,
       totalChunksProcessed = 0;

  /// Create fresh extraction result
  ExtractionResult.fresh({
    required this.recipes,
    required this.totalChunksProcessed,
    this.sourceInfo,
    this.warnings = const [],
  }) : isFromCache = false,
       cacheSource = null,
       extractedAt = DateTime.now();

  /// Create partial success result
  ExtractionResult.partialSuccess({
    required this.recipes,
    required this.totalChunksProcessed,
    required this.warnings,
    this.sourceInfo,
  }) : isFromCache = false,
       cacheSource = null,
       extractedAt = DateTime.now();

  bool get hasRecipes => recipes.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  int get recipeCount => recipes.length;

  @override
  String toString() {
    return 'ExtractionResult(recipes: ${recipes.length}, fromCache: $isFromCache, source: $cacheSource)';
  }
}