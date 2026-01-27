import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../app/app_colors.dart';
import '../app/app_text_styles.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
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
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: Colors.grey[300],
                  width: double.infinity,
                  child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.restaurant_menu,
                                color: AppColors.primary, size: 40),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.restaurant_menu,
                              color: AppColors.primary, size: 40),
                        ),
                ),
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
}
