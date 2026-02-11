import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/recipe.dart';
import '../../services/image_service.dart';
import '../../app/app_colors.dart';

class SmartRecipeImage extends StatefulWidget {
  final Recipe recipe;
  final ImageSize size;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showFallback;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const SmartRecipeImage({
    super.key,
    required this.recipe,
    this.size = ImageSize.card,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.showFallback = true,
    this.placeholder,
    this.errorWidget,
    this.onTap,
  });

  @override
  State<SmartRecipeImage> createState() => _SmartRecipeImageState();
}

class _SmartRecipeImageState extends State<SmartRecipeImage> {
  final ImageService _imageService = ImageService();
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final imageUrl = await _imageService.getRecipeImageUrl(widget.recipe);
      final optimizedUrl = _imageService.getOptimizedImageUrl(imageUrl, widget.size);

      if (mounted) {
        setState(() {
          _imageUrl = optimizedUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading image for ${widget.recipe.title}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensionsForSize(widget.size);
    
    Widget imageWidget;

    if (_isLoading) {
      imageWidget = _buildLoadingPlaceholder(dimensions);
    } else if (_hasError || _imageUrl == null) {
      imageWidget = _buildErrorWidget(dimensions);
    } else {
      imageWidget = _buildNetworkImage(dimensions);
    }

    // Wrap with GestureDetector if onTap is provided
    if (widget.onTap != null) {
      imageWidget = GestureDetector(
        onTap: widget.onTap,
        child: imageWidget,
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  Widget _buildNetworkImage(ImageDimensions dimensions) {
    return CachedNetworkImage(
      imageUrl: _imageUrl!,
      width: dimensions.width.toDouble(),
      height: dimensions.height.toDouble(),
      fit: widget.fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(dimensions),
      errorWidget: (context, url, error) {
        debugPrint('❌ Network image error for ${widget.recipe.title}: $error');
        return _buildErrorWidget(dimensions);
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      // Add timeout and retry logic
      httpHeaders: const {
        'User-Agent': 'Crave-App/1.0',
      },
      cacheManager: DefaultCacheManager(),
      maxWidthDiskCache: dimensions.width * 2, // 2x for high DPI
      maxHeightDiskCache: dimensions.height * 2,
    );
  }

  Widget _buildLoadingPlaceholder(ImageDimensions dimensions) {
    if (widget.placeholder != null) {
      return SizedBox(
        width: dimensions.width.toDouble(),
        height: dimensions.height.toDouble(),
        child: widget.placeholder!,
      );
    }

    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface.withOpacity(0.3),
      child: Container(
        width: dimensions.width.toDouble(),
        height: dimensions.height.toDouble(),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.restaurant,
            color: AppColors.textSecondary,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ImageDimensions dimensions) {
    if (widget.errorWidget != null) {
      return SizedBox(
        width: dimensions.width.toDouble(),
        height: dimensions.height.toDouble(),
        child: widget.errorWidget!,
      );
    }

    if (!widget.showFallback) {
      return _buildLoadingPlaceholder(dimensions);
    }

    return Container(
      width: dimensions.width.toDouble(),
      height: dimensions.height.toDouble(),
      decoration: BoxDecoration(
        gradient: _getGradientForRecipe(widget.recipe),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: FoodPatternPainter(),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForRecipe(widget.recipe),
                  color: Colors.white.withOpacity(0.9),
                  size: _getIconSizeForImageSize(widget.size),
                ),
                if (widget.size != ImageSize.thumbnail) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      widget.recipe.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getFontSizeForImageSize(widget.size),
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageDimensions _getDimensionsForSize(ImageSize size) {
    switch (size) {
      case ImageSize.thumbnail:
        return const ImageDimensions(80, 80);
      case ImageSize.card:
        return const ImageDimensions(200, 150);
      case ImageSize.detail:
        return const ImageDimensions(400, 300);
      case ImageSize.fullscreen:
        return const ImageDimensions(800, 600);
    }
  }

  LinearGradient _getGradientForRecipe(Recipe recipe) {
    // Generate gradient based on recipe category or tags
    final colors = _getColorsForRecipe(recipe);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  List<Color> _getColorsForRecipe(Recipe recipe) {
    return [AppColors.accent, AppColors.accent.withOpacity(0.85)];
  }

  IconData _getIconForRecipe(Recipe recipe) {
    final tags = recipe.tags ?? [];
    final title = recipe.title.toLowerCase();
    
    if (tags.contains('Breakfast') || title.contains('breakfast')) {
      return Icons.free_breakfast;
    } else if (tags.contains('Dessert') || title.contains('cake') || title.contains('cookie')) {
      return Icons.cake;
    } else if (title.contains('soup') || title.contains('stew')) {
      return Icons.soup_kitchen;
    } else if (title.contains('salad')) {
      return Icons.eco;
    } else if (title.contains('pizza')) {
      return Icons.local_pizza;
    } else if (title.contains('burger') || title.contains('sandwich')) {
      return Icons.lunch_dining;
    } else {
      return Icons.restaurant;
    }
  }

  double _getIconSizeForImageSize(ImageSize size) {
    switch (size) {
      case ImageSize.thumbnail:
        return 24;
      case ImageSize.card:
        return 32;
      case ImageSize.detail:
        return 48;
      case ImageSize.fullscreen:
        return 64;
    }
  }

  double _getFontSizeForImageSize(ImageSize size) {
    switch (size) {
      case ImageSize.thumbnail:
        return 10;
      case ImageSize.card:
        return 12;
      case ImageSize.detail:
        return 16;
      case ImageSize.fullscreen:
        return 20;
    }
  }
}

// Custom painter for background pattern
class FoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw subtle food-related pattern
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small circles (representing food items)
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Convenience widgets for common use cases
class RecipeCardImage extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCardImage({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRecipeImage(
      recipe: recipe,
      size: ImageSize.card,
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
    );
  }
}

class RecipeThumbnailImage extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeThumbnailImage({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRecipeImage(
      recipe: recipe,
      size: ImageSize.thumbnail,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
    );
  }
}

class RecipeDetailImage extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeDetailImage({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRecipeImage(
      recipe: recipe,
      size: ImageSize.detail,
      borderRadius: BorderRadius.circular(16),
      fit: BoxFit.cover,
      onTap: onTap,
    );
  }
}