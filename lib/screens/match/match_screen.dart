import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../providers/user_provider.dart';
import '../../widgets/recipe_card.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../../services/recipe_matching_service.dart';

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
                
                // Content
                Expanded(
                  child: filteredMatches.isEmpty
                    ? _buildEmptyState(allMatches.isEmpty)
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredMatches.length,
                        itemBuilder: (context, index) {
                          final match = filteredMatches[index];
                          return RecipeCard(
                            recipe: match.recipe,
                            matchPercentage: match.matchPercentage.round(),
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(recipe: match.recipe)
                                ),
                              );
                            },
                          );
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
                ? 'Add ingredients in the Pantry tab to see which recipes you can cook!' 
                : 'Try a different search term or add more ingredients to your fridge.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
