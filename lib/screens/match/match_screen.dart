import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../models/match_result.dart'; // NEW
import '../../providers/user_provider.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final allMatches = userProvider.recipeMatches;
            
            // Filter matches based on search query
            final filteredMatches = allMatches.where((match) {
              final titleMatch = match.recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
              final ingredientMatch = match.recipe.ingredients.any(
                (ing) => ing.toLowerCase().contains(_searchQuery.toLowerCase())
              );
              return titleMatch || ingredientMatch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Search
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios_new, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Text('Recipe Matches', style: AppTextStyles.headlineMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        allMatches.isEmpty 
                          ? 'Add ingredients to see matches' 
                          : 'Top matches for your kitchen',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search within matches...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear), 
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                }
                              )
                            : null,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
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
                
                // Content
                Expanded(
                  child: filteredMatches.isEmpty
                    ? _buildEmptyState(allMatches.isEmpty)
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65, // Taller for extra info
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredMatches.length,
                        itemBuilder: (context, index) {
                          final match = filteredMatches[index];
                          return _buildMatchCard(context, match);
                        },
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, SmartMatchResult match) {
    Color badgeColor;
    String badgeText;
    
    switch (match.tier) {
      case MatchTier.cookNow:
        badgeColor = const Color(0xFF4CAF50); // Green
        badgeText = 'Cook Now';
        break;
      case MatchTier.missingFew:
        badgeColor = const Color(0xFFFFC107); // Amber
        badgeText = 'Missing Few';
        break;
      case MatchTier.needShopping:
        badgeColor = const Color(0xFFFF9800); // Orange
        badgeText = 'Shop';
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Low Match';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: match.recipe)
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: match.recipe.imageUrl != null
                      ? Image.network(
                          match.recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                        )
                      : Container(color: Colors.grey[200], child: const Icon(Icons.restaurant)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.pie_chart, size: 14, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        '${match.matchPercentage.round()}% Match',
                        style: TextStyle(
                            fontSize: 12, 
                            color: badgeColor,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (match.suggestions.isNotEmpty)
                    Text(
                      '💡 ${match.suggestions.first}', // Show first suggestion
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    )
                  else
                    Text(
                        'Missing: ${match.missingIngredients.length} items',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool noIngredients) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              noIngredients ? Icons.kitchen : Icons.search_off, 
              size: 64, 
              color: AppColors.textSecondary.withOpacity(0.5)
            ),
            const SizedBox(height: 16),
            Text(
              noIngredients ? 'Your kitchen is empty' : 'No matches found',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              noIngredients 
                ? 'Add ingredients in the Pantry tab to unlock recipes!' 
                : 'Try adding more ingredients or check spelling.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
