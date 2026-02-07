import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../images/smart_recipe_image.dart';
import '../../services/image_service.dart';

class RecipeCardHorizontal extends StatelessWidget {
  final Recipe recipe;
  final String? time;
  final String? calories;
  final int matchPercentage;
  final VoidCallback onTap;

  const RecipeCardHorizontal({
    super.key,
    required this.recipe,
    this.time,
    this.calories,
    required this.matchPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Stack(
              children: [
                SmartRecipeImage(
                  recipe: recipe,
                  size: ImageSize.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  fit: BoxFit.cover,
                ),
                // Match Badge
                if (matchPercentage > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles, size: 12, color: AppColors.warmPeach),
                          const SizedBox(width: 4),
                          Text(
                            '$matchPercentage%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (time != null || recipe.cookTime != null)
                        _buildInfoChip(LucideIcons.clock, time ?? '${recipe.cookTime ?? 15}m'),
                      if (calories != null) ...[
                        const SizedBox(width: 8),
                        _buildInfoChip(LucideIcons.flame, calories!),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.slate),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate),
        ),
      ],
    );
  }
}
