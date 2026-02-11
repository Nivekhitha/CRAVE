import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../services/recipe_matching_service.dart';
import '../../widgets/images/smart_recipe_image.dart';
import '../../screens/recipe_detail/recipe_detail_screen.dart';
import '../../screens/pantry/pantry_screen.dart';
import '../../services/image_service.dart';
import '../../providers/user_provider.dart';

class RecipeSuggestionsWidget extends StatelessWidget {
  final bool showHeader;
  final int maxSuggestions;
  final String? filterMealType;

  const RecipeSuggestionsWidget({
    super.key,
    this.showHeader = true,
    this.maxSuggestions = 5,
    this.filterMealType,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final pantryItems = userProvider.pantryList;
        final isLoading = userProvider.suggestionsLoading;
        
        // Always use ingredient-based matching; filter by meal type when set. No overlapping recipes.
        List<RecipeMatch> suggestions;
        if (filterMealType != null) {
          suggestions = userProvider.getRecipeMatchesForMeal(filterMealType!);
        } else {
          suggestions = userProvider.recipeMatches;
        }
        // Dedupe by recipe id so the same recipe never appears twice
        final seenIds = <String>{};
        suggestions = suggestions.where((m) => seenIds.add(m.recipe.id)).toList();
        suggestions = suggestions.take(maxSuggestions).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildHeader(context, suggestions.length, pantryItems.length),
            const SizedBox(height: 16),
            _buildContent(context, suggestions, pantryItems, isLoading, userProvider),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int suggestionsCount, int pantryCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filterMealType != null 
                    ? '$filterMealType Ideas' 
                    : 'Recipe Suggestions',
                style: AppTextStyles.headlineMedium,
              ),
              if (pantryCount > 0)
                Text(
                  'Based on $pantryCount ingredients • $suggestionsCount matches',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
            if (suggestionsCount > maxSuggestions)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/match');
              },
              child: Text(
                'See All',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<RecipeMatch> suggestions,
    List<Map<String, dynamic>> pantryItems,
    bool isLoading,
    UserProvider userProvider,
  ) {
    // Case 1: Loading
    if (isLoading) {
      return _buildLoadingState();
    }

    // Case 2: No pantry items
    if (pantryItems.isEmpty) {
      return _buildEmptyPantryState(context);
    }

    // Case 3: No suggestions
    if (suggestions.isEmpty) {
      return _buildNoSuggestionsState(context, userProvider);
    }

    // Case 4: Show suggestions
    return _buildSuggestionsList(context, suggestions);
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              'Finding recipe matches...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPantryState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 48,
            color: AppColors.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Add Ingredients to Get Suggestions',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us what\'s in your fridge and we\'ll suggest recipes you can make right now!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantryScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredients'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSuggestionsState(BuildContext context, UserProvider userProvider) {
    final oneIngredientAway = userProvider.getOneIngredientAway();
    final ingredientSuggestions = userProvider.getIngredientSuggestions().take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: AppColors.accent.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No Perfect Matches Yet',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a few more ingredients to unlock delicious recipes!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Show "one ingredient away" recipes if available
          if (oneIngredientAway.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Almost there! Add one more ingredient:',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            ...oneIngredientAway.take(2).map((Recipe recipe) {
              final matches = userProvider.recipeMatches.where((m) => m.recipe.id == recipe.id).toList();
              final missing = (matches.isNotEmpty && matches.first.missingIngredients.isNotEmpty)
                  ? matches.first.missingIngredients.first
                  : 'One ingredient away';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: AppTextStyles.labelMedium,
                          ),
                          Text(
                            'Add: $missing',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Add missing ingredient to grocery list
                        userProvider.addGroceryItem(missing);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $missing to grocery list!')),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],

          // Show ingredient suggestions
          if (ingredientSuggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Try adding:',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ingredientSuggestions.map((ingredient) {
                return ActionChip(
                  label: Text(ingredient),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantryScreen()),
                    );
                  },
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantryScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add More Ingredients'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, List<RecipeMatch> suggestions) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final match = suggestions[index];
          final recipe = match.recipe;
          
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with smart loading
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          SmartRecipeImage(
                            recipe: recipe,
                            size: ImageSize.card,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            fit: BoxFit.cover,
                          ),
                          // Match percentage badge overlay
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getMatchColor(match.matchPercentage),
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
                                '${match.matchPercentage.round()}%',
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
                    
                    // Recipe info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: AppTextStyles.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (recipe.cookTime != null)
                              Text(
                                '${recipe.cookTime} min',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            const Spacer(),
                            if (match.missingIngredients.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Need: ${match.missingIngredients.length} more',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return AppColors.accent;
    if (percentage >= 60) return AppColors.accent.withOpacity(0.85);
    return AppColors.accent.withOpacity(0.6);
  }
}