import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../widgets/recipe_card.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Recipe> recipes = [
      Recipe(id: '1', title: 'Avocado Toast', category: 'Breakfast', imageUrl: '', durationMinutes: 10, difficulty: 'Easy', calories: 250, rating: 4.8),
      Recipe(id: '2', title: 'Grilled Chicken', category: 'Lunch', imageUrl: '', durationMinutes: 30, difficulty: 'Medium', calories: 450, rating: 4.5),
      Recipe(id: '3', title: 'Pasta Carbonara', category: 'Dinner', imageUrl: '', durationMinutes: 20, difficulty: 'Medium', calories: 600, rating: 4.7),
      Recipe(id: '4', title: 'Berry Smoothie', category: 'Breakfast', imageUrl: '', durationMinutes: 5, difficulty: 'Easy', calories: 180, rating: 4.9),
      Recipe(id: '5', title: 'Caesar Salad', category: 'Lunch', imageUrl: '', durationMinutes: 15, difficulty: 'Easy', calories: 300, rating: 4.6),
      Recipe(id: '6', title: 'Steak & Veggies', category: 'Dinner', imageUrl: '', durationMinutes: 45, difficulty: 'Hard', calories: 700, rating: 4.8),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discover', style: AppTextStyles.displaySmall),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Recipes, Ingredients...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    recipe: recipes[index],
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeDetailScreen()));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
