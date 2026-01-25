import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';

import '../../models/recipe.dart'; // Add model import

class RecipeDetailScreen extends StatefulWidget {
  final Recipe? recipe; // Change to Recipe object

  const RecipeDetailScreen({super.key, this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    // Fallback Mock Data IF recipe is null (for testing/preview)
    final Recipe recipe = widget.recipe ?? Recipe(
      id: 'mock',
      title: 'One-Pot Creamy Pesto Pasta',
      description: 'Perfect for busy evenings. This creamy pasta combines fresh basil pesto with a touch of heavy cream for a silky finish.',
      ingredients: ['Penne Pasta', 'Garlic Cloves', 'Heavy Cream', 'Basil Pesto', 'Parmesan Cheese'],
      instructions: [
        'Boil water in a large pot. Add salt and pasta. Cook until al dente.',
        'Reserve 1/2 cup of pasta water. Drain the rest.',
        'In the same pot (or a pan), add the pesto and heavy cream. Simmer for 1-2 mins.',
        'Toss the pasta in the sauce. Add pasta water if too thick.',
        'Serve hot with parmesan cheese.'
      ],
      cookTime: 20,
      difficulty: 'Easy',
      isPremium: false, 
      imageUrl: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
      createdAt: DateTime.now(),
    );

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Determine which ingredients we have
        final pantryNames = userProvider.pantryList.map((e) => (e['name'] as String).toLowerCase()).toSet();
        
        // Map ingredients to display model
        final displayIngredients = recipe.ingredients.map((rawName) {
           bool hasIt = false;
           // Fuzzy check
           final lower = rawName.toLowerCase();
           if (pantryNames.contains(lower)) {
             hasIt = true;
           } else {
             // Basic containment check
             hasIt = pantryNames.any((p) => p.contains(lower) || lower.contains(p));
           }
           
           return {
             'name': rawName, 
             'amount': '', // Recipe model doesn't split amount/name yet (MVP)
             'has': hasIt
           };
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_ios_new, 
                        onTap: () => Navigator.pop(context)
                      ),
                      Text(
                        'Recipe Detail', 
                        style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)
                      ),
                      _CircleButton(icon: Icons.share, onTap: () {}),
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
                        
                        // Hero Image Card
                        Stack(
                          children: [
                            Container(
                              height: 320,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                image: const DecorationImage(
                                    image: NetworkImage(recipe.imageUrl ?? 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601'),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                              ),
                              // Dark Gradient Overlay (Keep dark for text visibility on image)
                              Container(
                                height: 320,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              // Title & Badge content
                              Positioned(
                                bottom: 24,
                                left: 24,
                                right: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (recipe.cookCount > 100) // Simple trending logic
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'TRENDING', 
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.white, 
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          )
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Text(
                                      recipe.title,
                                      style: AppTextStyles.headlineLarge.copyWith(
                                        color: Colors.white, 
                                        height: 1.1,
                                        fontSize: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
  
                          // Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.schedule, 
                                  label: 'TIME', 
                                  value: '${recipe.cookTime} min'
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.restaurant_menu, // Using as difficulty icon
                                  label: 'DIFFICULTY', 
                                  value: recipe.difficulty ?? 'Medium'
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
  
                          // Description
                          Text(
                            recipe.description ?? 'No description available for this recipe.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 32),
  
                          // Ingredients Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.kitchen, size: 20, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Text('Ingredients', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 16),
  
                          // Ingredients List
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayIngredients.length,
                            itemBuilder: (context, index) {
                              final item = displayIngredients[index];
                              return _IngredientTile(item: item);
                            },
                          ),
                          
                          const SizedBox(height: 32),
  
                          // Instructions Header
                           Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.menu_book, size: 20, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Text('Preparation', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 16),
  
                          // Instructions List
                          if (recipe.instructions.isNotEmpty)
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: recipe.instructions.length,
                              itemBuilder: (context, index) {
                                final step = recipe.instructions[index];
                              final isCompleted = _completedSteps.contains(index);
                              return GestureDetector(
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
                                  margin: const EdgeInsets.only(bottom: 24),
                                  color: Colors.transparent, // Hit test
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isCompleted ? Colors.green : AppColors.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: isCompleted 
                                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                                          : Text(
                                              '${index + 1}',
                                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                                            ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            color: isCompleted ? AppColors.textSecondary.withOpacity(0.5) : AppColors.textPrimary,
                                            height: 1.5,
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            decorationColor: AppColors.textSecondary
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Bottom Padding for FAB
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          

          // Floating Cook Button
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   // Update Logic
                   Provider.of<UserProvider>(context, listen: false).completeCooking();
                   
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(
                       content: Text('Cooking Completed! Streak Updated 🔥'),
                       backgroundColor: AppColors.primary,
                       behavior: SnackBarBehavior.floating,
                     )
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.soup_kitchen, size: 24),
                    const SizedBox(width: 12),
                    Text('Cook Today', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface, // Light background
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _IngredientTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool hasItem = item['has'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: hasItem ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: hasItem ? AppColors.primary : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: hasItem ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item['name'],
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Text(
            item['amount'],
             style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
