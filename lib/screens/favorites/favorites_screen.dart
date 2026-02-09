import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../widgets/home_revamp/recipe_card_revamp.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Favorites'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final favorites = userProvider.savedRecipes;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Heart recipes you love to save them here!',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final recipe = favorites[index];
              return RecipeCardRevamp(
                recipe: recipe,
                isFavorite: true,
                onFavorite: () => userProvider.toggleSaveRecipe(recipe.id),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
