import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../widgets/suggestions/recipe_suggestions_widget.dart';
import '../../widgets/discovery/search_bar_widget.dart';
import '../../widgets/discovery/filter_chip_list.dart';

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
                        // TODO: Navigate to recipe detail
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
        
        return Container(
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