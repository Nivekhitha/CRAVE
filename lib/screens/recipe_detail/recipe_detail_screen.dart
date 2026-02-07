import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../services/user_stats_service.dart';
import '../../models/recipe.dart';
import '../cooking/cooking_session_screen.dart';
import '../../widgets/images/smart_recipe_image.dart';
import '../../services/image_service.dart';
import '../../utils/ingredient_normalizer.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeDetailScreen({super.key, this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    // Fallback Mock Data IF recipe is null
    final Recipe recipe = widget.recipe ??
        Recipe(
          id: 'mock',
          title: 'One-Pot Creamy Pesto Pasta',
          description:
              'Perfect for busy evenings. This creamy pasta combines fresh basil pesto with a touch of heavy cream for a silky finish.',
          ingredients: [
            'Penne Pasta',
            'Garlic Cloves',
            'Heavy Cream',
            'Basil Pesto',
            'Parmesan Cheese'
          ],
          instructions:
              'Boil water in a large pot. Add salt and pasta. Cook until al dente.\nReserve 1/2 cup of pasta water. Drain the rest.\nIn the same pot (or a pan), add the pesto and heavy cream. Simmer for 1-2 mins.\nToss the pasta in the sauce. Add pasta water if too thick.\nServe hot with parmesan cheese.',
          cookTime: 20,
          difficulty: 'Easy',
          isPremium: false,
          imageUrl:
              'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
          createdAt: DateTime.now(),
          source: 'manual',
        );

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Use production-grade normalization for matching
        final pantrySet = normalizeIngredientSet(
          userProvider.pantryList
              .map((e) => e['name'] as String? ?? '')
              .toList(),
        );

        // Map ingredients to display model
        final displayIngredients = recipe.ingredients.map((rawName) {
          final normalized = normalizeIngredient(rawName);
          final hasIt = normalized.isNotEmpty && pantrySet.contains(normalized);

          return {'name': rawName, 'amount': '', 'has': hasIt};
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Custom App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleButton(
                              icon: Icons.arrow_back_ios_new,
                              onTap: () => Navigator.pop(context)),
                          Text('Recipe Detail',
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.textPrimary)),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, _) {
                              final isSaved = userProvider.isRecipeSaved(recipe.id);
                              return _CircleButton(
                                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                                onTap: () async {
                                  try {
                                    await userProvider.toggleSaveRecipe(recipe.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isSaved ? 'Recipe unsaved' : 'Recipe saved!'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to save recipe'),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.only(top: 80, left: 16, right: 16),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Recipe Title
                            Text(
                              recipe.title,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Recipe Info
                            Row(
                              children: [
                                const Icon(Icons.timer,
                                    color: AppColors.textSecondary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${recipe.cookTime} min',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.signal_cellular_alt,
                                    color: AppColors.textSecondary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  recipe.difficulty ?? 'Easy',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Hero Image Card
                            SmartRecipeImage(
                              recipe: recipe,
                              size: ImageSize.detail,
                              borderRadius: BorderRadius.circular(16),
                              fit: BoxFit.cover,
                            ),

                            const SizedBox(height: 32),

                            // Description
                            if (recipe.description != null &&
                                recipe.description!.isNotEmpty) ...[
                              Text(
                                recipe.description!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Ingredients Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Ingredients',
                                    style: AppTextStyles.titleMedium),
                                if (displayIngredients
                                    .where((i) => !(i['has'] as bool))
                                    .isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      final missing = displayIngredients
                                          .where((i) => !(i['has'] as bool))
                                          .map((i) => i['name'] as String)
                                          .toList();
                                      for (final item in missing) {
                                        userProvider.addGroceryItem({
                                          'name': item,
                                          'isChecked': false,
                                          'category': 'Other'
                                        });
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  '${missing.length} items added to grocery list'),
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
                                          ));
                                    },
                                    icon: const Icon(Icons.add_shopping_cart,
                                        size: 16),
                                    label: const Text('Add Missing'),
                                    style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Ingredients List
                            ...displayIngredients.map((ingredient) {
                              final hasIt = ingredient['has'] as bool;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: hasIt
                                            ? AppColors.primary
                                                .withValues(alpha: 0.1)
                                            : Colors.grey
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        _getIngredientIcon(
                                            ingredient['name'] as String),
                                        color: hasIt
                                            ? AppColors.primary
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ingredient['name'] as String,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: hasIt
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                          decoration: hasIt
                                              ? null
                                              : TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      hasIt
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: hasIt ? Colors.green : Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 32),

                            // Instructions Section
                            Text('Instructions',
                                style: AppTextStyles.titleMedium),
                            const SizedBox(height: 16),

                            // Instructions List
                            ...(recipe.instructions ?? '')
                                .split('\n')
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final instruction = entry.value.trim();
                              if (instruction.isEmpty)
                                return const SizedBox.shrink();

                              final isCompleted =
                                  _completedSteps.contains(index);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isCompleted) {
                                        _completedSteps.remove(index);
                                      } else {
                                        _completedSteps.add(index);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? AppColors.primary
                                              .withValues(alpha: 0.1)
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCompleted
                                            ? AppColors.primary
                                                .withValues(alpha: 0.3)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? AppColors.primary
                                                : AppColors.surface,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isCompleted
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                          child: isCompleted
                                              ? const Icon(Icons.check,
                                                  color: Colors.white, size: 16)
                                              : Center(
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            instruction,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: isCompleted
                                                  ? AppColors.textSecondary
                                                  : AppColors.textPrimary,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),

                            const SizedBox(
                                height: 100), // Bottom padding for FAB
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Action Buttons
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    // Start Cooking Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CookingSessionScreen(recipe: recipe),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: const Text('Start Cooking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Cook Today Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          userProvider.completeCooking();
                          // Track recipe completion
                          context.read<UserStatsService>().recordRecipeCooked();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recipe completed! 🎉'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(top: 80, left: 16, right: 16),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          'Save',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIngredientIcon(String name) {
    final key = name.toLowerCase();
    if (key.contains('egg')) return Icons.egg_outlined;
    if (key.contains('milk') || key.contains('dairy')) return Icons.local_drink;
    if (key.contains('meat') || key.contains('chicken') || key.contains('beef'))
      return Icons.set_meal;
    if (key.contains('vegetable') ||
        key.contains('tomato') ||
        key.contains('onion')) return Icons.eco;
    if (key.contains('fruit')) return Icons.apple;
    if (key.contains('bread') || key.contains('flour'))
      return Icons.bakery_dining;
    return Icons.kitchen;
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
