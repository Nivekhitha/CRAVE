import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../app/app_colors.dart';
import '../app/app_text_styles.dart';
import 'images/smart_recipe_image.dart';
import '../services/image_service.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int? matchPercentage;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.matchPercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  SmartRecipeImage(
                    recipe: recipe,
                    size: ImageSize.card,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  if (matchPercentage != null && matchPercentage! > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getMatchColor(matchPercentage!.toDouble()),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$matchPercentage%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (recipe.tags?.isNotEmpty ?? false)
                        ? recipe.tags!.first.toUpperCase()
                        : 'RECIPE',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${recipe.totalTime ?? 0} min',
                          style: AppTextStyles.bodySmall),
                      const Spacer(),
                      // Rating removed as it is not in the model
                      if (recipe.isPremium) ...[
                        const Icon(Icons.lock, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('Premium',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.amber)),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
