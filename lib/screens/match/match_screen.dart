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
    // Mock Data
    final List<Recipe> recipes = [
      Recipe(
        id: '1', 
        title: 'Avocado Toast', 
        tags: ['Breakfast', 'Easy'],
        imageUrl: '', 
        prepTime: 10,
        source: 'manual',
        ingredients: ['Avocado', 'Bread', 'Salt', 'Pepper']
      ),
      Recipe(
        id: '2', 
        title: 'Grilled Chicken', 
        tags: ['Lunch', 'Medium'],
        imageUrl: '', 
        prepTime: 30,
        source: 'manual',
        ingredients: ['Chicken Breast', 'Spices']
      ),
      Recipe(
        id: '3', 
        title: 'Pasta Carbonara', 
        tags: ['Dinner', 'Medium'],
        imageUrl: '', 
        prepTime: 20, 
        source: 'manual',
        ingredients: ['Pasta', 'Eggs', 'Cheese']
      ),
      Recipe(
        id: '4', 
        title: 'Berry Smoothie', 
        tags: ['Breakfast', 'Easy'],
        imageUrl: '', 
        prepTime: 5, 
        source: 'manual',
        ingredients: ['Berries', 'Yogurt', 'Milk']
      ),
      Recipe(
        id: '5', 
        title: 'Caesar Salad', 
        tags: ['Lunch', 'Easy'],
        imageUrl: '', 
        prepTime: 15,
        source: 'manual',
        ingredients: ['Romaine', 'Croutons', 'Dressing']
      ),
      Recipe(
        id: '6', 
        title: 'Steak & Veggies', 
        tags: ['Dinner', 'Hard'],
        imageUrl: '', 
        prepTime: 45, 
        source: 'manual',
        ingredients: ['Steak', 'Broccoli', 'Carrots']
      ),
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
