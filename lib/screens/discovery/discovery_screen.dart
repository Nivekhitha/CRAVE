import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../models/recipe.dart';
import '../../widgets/suggestions/recipe_suggestions_widget.dart';
import '../../widgets/discovery/search_bar_widget.dart';
import '../../widgets/discovery/filter_chip_list.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  final List<String> _filters = [
    'All',
    'Quick & Easy',
    'Healthy',
    'Comfort Food',
    'Vegetarian',
    'Dessert',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSearchSection(),
              _buildFilterSection(),
              _buildFeaturedSection(),
              _buildSuggestionsSection(),
              _buildTrendingSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover',
              style: AppTextStyles.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find new recipes and cooking inspiration',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SearchBarWidget(
          controller: _searchController,
          onChanged: _handleSearch,
          onSubmitted: _handleSearchSubmit,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: FilterChipList(
          filters: _filters,
          selectedFilter: _selectedFilter,
          onFilterSelected: _handleFilterSelected,
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Recipes',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeaturedCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.accent.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _FeaturedPatternPainter(),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Chef\'s Choice',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Mediterranean Quinoa Bowl',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A nutritious and colorful bowl packed with fresh vegetables, quinoa, and a tangy lemon dressing.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFeatureTag('25 min', Icons.access_time),
                    const SizedBox(width: 16),
                    _buildFeatureTag('Healthy', Icons.favorite),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to featured recipe detail
                        final featuredRecipe = Recipe(
                          id: 'featured_mediterranean_quinoa',
                          title: 'Mediterranean Quinoa Bowl',
                          description: 'A nutritious and colorful bowl packed with fresh vegetables, quinoa, and a tangy lemon dressing.',
                          ingredients: ['Quinoa', 'Cherry Tomatoes', 'Cucumber', 'Red Onion', 'Feta Cheese', 'Olives', 'Lemon', 'Olive Oil', 'Fresh Herbs'],
                          instructions: 'Cook quinoa according to package directions.\nChop all vegetables into bite-sized pieces.\nCombine quinoa and vegetables in a large bowl.\nWhisk together lemon juice, olive oil, salt, and pepper for dressing.\nToss everything together and top with feta cheese and fresh herbs.\nServe chilled or at room temperature.',
                          cookTime: 25,
                          difficulty: 'Easy',
                          source: 'manual',
                          tags: ['Healthy', 'Vegetarian', 'Quick & Easy'],
                          imageUrl: 'https://source.unsplash.com/800x600/?mediterranean,quinoa,bowl',
                          createdAt: DateTime.now(),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: featuredRecipe),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('View Recipe'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    return SliverToBoxAdapter(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return RecipeSuggestionsWidget(
            showHeader: true,
            maxSuggestions: 10,
            filterMealType: _selectedFilter == 'All' ? null : _selectedFilter,
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending This Week',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList() {
    final trendingRecipes = [
      _TrendingRecipe('Avocado Toast Variations', '2.3k views', Icons.trending_up, Colors.green),
      _TrendingRecipe('One-Pot Pasta Recipes', '1.8k views', Icons.trending_up, Colors.orange),
      _TrendingRecipe('Healthy Smoothie Bowls', '1.5k views', Icons.trending_up, Colors.purple),
      _TrendingRecipe('Air Fryer Vegetables', '1.2k views', Icons.trending_up, Colors.blue),
    ];

    return Column(
      children: trendingRecipes.asMap().entries.map((entry) {
        final index = entry.key;
        final recipe = entry.value;
        
        return GestureDetector(
          onTap: () => _navigateToTrendingRecipe(recipe.title),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: recipe.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: recipe.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.views,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  recipe.icon,
                  color: recipe.color,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleSearch(String query) {
    // TODO: Implement search functionality
    debugPrint('Searching for: $query');
  }

  void _handleSearchSubmit(String query) {
    // TODO: Navigate to search results
    debugPrint('Search submitted: $query');
  }

  void _handleFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // TODO: Filter recipes based on selection
  }

  void _navigateToTrendingRecipe(String title) {
    // Create mock recipe based on trending title
    Recipe trendingRecipe;
    
    switch (title) {
      case 'Avocado Toast Variations':
        trendingRecipe = Recipe(
          id: 'trending_avocado_toast',
          title: title,
          description: 'Elevate your breakfast with these creative avocado toast variations. From classic to gourmet!',
          ingredients: ['Bread', 'Avocado', 'Lemon', 'Salt', 'Pepper', 'Cherry Tomatoes', 'Feta Cheese', 'Red Pepper Flakes'],
          instructions: 'Toast bread until golden brown.\nMash avocado with lemon juice, salt, and pepper.\nSpread avocado mixture on toast.\nTop with cherry tomatoes, feta cheese, and red pepper flakes.\nServe immediately.',
          cookTime: 10,
          difficulty: 'Easy',
          source: 'manual',
          tags: ['Quick & Easy', 'Healthy', 'Vegetarian'],
          imageUrl: 'https://source.unsplash.com/800x600/?avocado,toast',
          createdAt: DateTime.now(),
        );
        break;
      case 'One-Pot Pasta Recipes':
        trendingRecipe = Recipe(
          id: 'trending_one_pot_pasta',
          title: title,
          description: 'Easy one-pot pasta that cooks everything together for minimal cleanup and maximum flavor.',
          ingredients: ['Pasta', 'Garlic', 'Cherry Tomatoes', 'Spinach', 'Olive Oil', 'Parmesan', 'Basil', 'Vegetable Broth'],
          instructions: 'Add pasta, garlic, tomatoes, and broth to a large pot.\nBring to a boil, then reduce heat and simmer.\nStir occasionally until pasta is cooked and liquid is absorbed.\nAdd spinach and stir until wilted.\nTop with parmesan and fresh basil.',
          cookTime: 20,
          difficulty: 'Easy',
          source: 'manual',
          tags: ['Quick & Easy', 'One Pot', 'Vegetarian'],
          imageUrl: 'https://source.unsplash.com/800x600/?pasta,pot',
          createdAt: DateTime.now(),
        );
        break;
      case 'Healthy Smoothie Bowls':
        trendingRecipe = Recipe(
          id: 'trending_smoothie_bowl',
          title: title,
          description: 'Thick, creamy smoothie bowls topped with fresh fruits, nuts, and seeds for a nutritious breakfast.',
          ingredients: ['Frozen Berries', 'Banana', 'Greek Yogurt', 'Almond Milk', 'Granola', 'Fresh Fruits', 'Chia Seeds', 'Honey'],
          instructions: 'Blend frozen berries, banana, yogurt, and almond milk until thick.\nPour into a bowl.\nTop with granola, fresh fruits, chia seeds, and a drizzle of honey.\nServe immediately.',
          cookTime: 5,
          difficulty: 'Easy',
          source: 'manual',
          tags: ['Quick & Easy', 'Healthy', 'Vegetarian'],
          imageUrl: 'https://source.unsplash.com/800x600/?smoothie,bowl',
          createdAt: DateTime.now(),
        );
        break;
      case 'Air Fryer Vegetables':
        trendingRecipe = Recipe(
          id: 'trending_air_fryer_veg',
          title: title,
          description: 'Crispy, perfectly roasted vegetables made easy in the air fryer with minimal oil.',
          ingredients: ['Broccoli', 'Carrots', 'Bell Peppers', 'Zucchini', 'Olive Oil', 'Garlic Powder', 'Salt', 'Pepper'],
          instructions: 'Cut vegetables into uniform pieces.\nToss with olive oil, garlic powder, salt, and pepper.\nPlace in air fryer basket in a single layer.\nAir fry at 400°F for 12-15 minutes, shaking halfway through.\nServe hot.',
          cookTime: 15,
          difficulty: 'Easy',
          source: 'manual',
          tags: ['Quick & Easy', 'Healthy', 'Vegetarian'],
          imageUrl: 'https://source.unsplash.com/800x600/?vegetables,roasted',
          createdAt: DateTime.now(),
        );
        break;
      default:
        trendingRecipe = Recipe(
          id: 'trending_default',
          title: title,
          description: 'A popular recipe trending this week!',
          ingredients: ['Ingredient 1', 'Ingredient 2', 'Ingredient 3'],
          instructions: 'Follow the steps to create this amazing dish.',
          cookTime: 30,
          difficulty: 'Medium',
          source: 'manual',
          createdAt: DateTime.now(),
        );
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipe: trendingRecipe),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // TODO: Refresh discovery content
    await Future.delayed(const Duration(seconds: 1));
  }
}

class _TrendingRecipe {
  final String title;
  final String views;
  final IconData icon;
  final Color color;

  _TrendingRecipe(this.title, this.views, this.icon, this.color);
}

class _FeaturedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw subtle pattern
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}