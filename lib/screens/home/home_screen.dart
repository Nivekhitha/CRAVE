import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../providers/user_provider.dart';
import '../../services/premium_service.dart';
import '../../services/journal_service.dart';
import '../../services/nutrition_service.dart';
import '../../services/image_service.dart';

// Screens
import '../discovery/discovery_screen.dart'; 
import '../grocery/grocery_screen.dart';
import '../pantry/pantry_screen.dart';
import '../add_recipe/add_recipe_options_screen.dart';
import '../emotional_cooking/emotional_cooking_screen.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../journal/journal_screen.dart'; 
import '../meal_planning/meal_planning_screen.dart';

// Revamp Widgets
import '../../widgets/home_revamp/home_header_revamp.dart';
import '../../widgets/home_revamp/quick_action_grid.dart';
import '../../widgets/home_revamp/mood_cooking_banner.dart';
import '../../widgets/home_revamp/section_header.dart';
import '../../widgets/home_revamp/recipe_card_revamp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PremiumService>(context, listen: false).initialize();
      Provider.of<JournalService>(context, listen: false).init();
      Provider.of<NutritionService>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final matches = userProvider.recipeMatchesUnique;
      final savedCount = userProvider.savedRecipes.length;
      final username = userProvider.username ?? 'Chef';
      final avatarUrl = ImageService().getUserAvatarUrl(username);
      final todayPickIds = matches.take(5).map((m) => m.recipe.id).toSet();
      final popularRecipes = userProvider.allRecipes
          .where((r) => !todayPickIds.contains(r.id))
          .take(5)
          .toList();

      return Scaffold( // Wrapped in scaffold to ensure bg color if used standalone
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Sticky Header
            SliverToBoxAdapter(
              child: SafeArea( // Move SafeArea inside for seamless sticky effect if we used SliverAppBar
                bottom: false,
                child: HomeHeaderRevamp(
                  userName: username,
                  avatarUrl: avatarUrl,
                ),
              ),
            ),

            // 2. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        'Search recipes...',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Quick Actions Grid (2x2)
            SliverToBoxAdapter(
              child: QuickActionGrid(
                pantryCount: userProvider.pantryList.length,
                groceryCount: userProvider.groceryList.where((i) => !(i['checked'] ?? false)).length,
                journalCount: userProvider.recipesCooked,
                onPantryTap: () => Navigator.pushNamed(context, '/pantry'),
                onGroceryTap: () => Navigator.pushNamed(context, '/grocery'),
                onPlannerTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealPlanningGate(child: MealPlanningScreen()))), // Assuming route or direct
                onJournalTap: () => Navigator.pushNamed(context, '/journal'),
              ),
            ),

            // 4. Mood Cooking Banner
            SliverToBoxAdapter(
              child: MoodCookingBanner(
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalCookingScreen())),
              ),
            ),

            // 5. Today's Picks
            SliverToBoxAdapter(
              child: SectionHeader(
                title: "Today's Picks",
                subtitle: "You can cook these right now! 🍳",
                onSeeAll: matches.isEmpty ? null : () {},
              ),
            ),

            if (matches.isEmpty)
               SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Add items to your pantry to see magic matches here!", 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
               )
            else
               SliverToBoxAdapter(
                child: SizedBox(
                   height: 280, // Height for card + shadow
                   child: ListView.builder(
                     scrollDirection: Axis.horizontal,
                     physics: const BouncingScrollPhysics(),
                     padding: const EdgeInsets.only(right: 20, bottom: 20),
                     itemCount: matches.length > 5 ? 5 : matches.length,
                     itemBuilder: (context, index) {
                       final recipe = matches[index].recipe;
                       return RecipeCardRevamp(
                         recipe: recipe,
                         isFavorite: userProvider.isRecipeSaved(recipe.id),
                         onFavorite: () => userProvider.toggleSaveRecipe(recipe.id),
                         onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))
                         ),
                       );
                     },
                   ),
                ),
               ),
               
             const SliverToBoxAdapter(child: SizedBox(height: 16)),

             // 6. Featured
             SliverToBoxAdapter(
               child: SectionHeader(
                 title: "Popular Recipes",
                 subtitle: "Trending in the Crave community",
                 onSeeAll: () => Navigator.pushNamed(context, '/discovery'),
               ),
             ),
             
             SliverToBoxAdapter(
                child: SizedBox(
                   height: 280,
                   child: ListView.builder(
                     scrollDirection: Axis.horizontal,
                     physics: const BouncingScrollPhysics(),
                     padding: const EdgeInsets.only(right: 20, bottom: 20),
                     itemCount: popularRecipes.length,
                     itemBuilder: (context, index) {
                       final recipe = popularRecipes[index];
                       return RecipeCardRevamp(
                         recipe: recipe,
                         isFavorite: userProvider.isRecipeSaved(recipe.id),
                         onFavorite: () => userProvider.toggleSaveRecipe(recipe.id),
                         onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))
                         ),
                       );
                     },
                   ),
                ),
             ),

             const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
          ],
        ),
      );
    });
  }
}

// Helper wrapper if needed, but normally MealPlanningScreen is guarded internally or by route
class MealPlanningGate extends StatelessWidget { 
  final Widget child;
  const MealPlanningGate({super.key, required this.child});
  @override 
  Widget build(BuildContext context) => child; 
}
