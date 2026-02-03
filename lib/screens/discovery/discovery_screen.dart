import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../widgets/discovery/search_bar_widget.dart';
import '../../widgets/discovery/filter_chip_list.dart';
import '../../widgets/cards/recipe_card_horizontal.dart'; // Reuse for now or create grid card
import '../../widgets/images/smart_recipe_image.dart';
import '../../services/image_service.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  final List<String> _filters = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Vegan',
    'Healthy',
  ];

  @override
  Widget build(BuildContext context) {
    // Access recipes via provider (mock logic for now if provider empty)
    // In real app, we might use a dedicated RecipeProvider for search
    
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header & Search
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.creamWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discover', style: AppTextStyles.displaySmall),
                  const SizedBox(height: 4),
                  Text('Find your next favorite meal', 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate)),
                  const SizedBox(height: 24),
                  SearchBarWidget(
                    controller: _searchController, 
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // Filters
            FilterChipList(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: 24),

            // Recipe Grid
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, provider, child) {
                  // Filter logic (mock/client-side)
                  // In MVP we might just show matches or all recipes
                  // For now, let's just show a grid of recent recipes or matches
                  
                  // Use dummy list if empty for visual verification
                  final recipes = provider.recipeMatches.map((m) => m.recipe).toList();
                  
                  if (recipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.searchX, size: 64, color: AppColors.slate.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('No recipes found', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text('Try adding some manually!', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75, // Taller cards
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      // Use a grid card variant (adapting horizontal card manually or reusing)
                      // For simplicity, building custom grid card inline here
                      return GestureDetector(
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
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
                              // Image
                              Expanded(
                                child: SmartRecipeImage(
                                  recipe: recipe,
                                  size: ImageSize.card,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(LucideIcons.clock, size: 14, color: AppColors.slate),
                                        const SizedBox(width: 4),
                                        Text('${recipe.cookTime ?? 15}m', style: AppTextStyles.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
