import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../services/premium_service.dart';
import '../../services/firestore_service.dart'; 

// Screens
import '../discovery/discovery_screen.dart'; 
import '../grocery/grocery_screen.dart';
import '../match/match_screen.dart';
import '../pantry/pantry_screen.dart';
import '../profile/profile_screen.dart';
import '../add_recipe/add_recipe_options_screen.dart';
import '../emotional_cooking/emotional_cooking_screen.dart';
import '../cooking_journey/cooking_journey_screen.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../journal/journal_screen.dart'; 

// New Widgets
import '../../widgets/home/home_header.dart';
import '../../widgets/cards/hero_action_card.dart';
import '../../widgets/cards/recipe_card_horizontal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PremiumService>(context, listen: false).initialize();
    });
  }

  final List<Widget> _screens = [
    const _HomeView(),
    const DiscoveryScreen(), 
    const SizedBox(), 
    const JournalScreen(), 
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      _showAddBottomSheet();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddRecipeOptionsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.freshMint,
          unselectedItemColor: AppColors.slate,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.compass), 
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.plusCircle, size: 32, color: AppColors.warmPeach),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bookOpen), 
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final matches = userProvider.recipeMatches;
      final username = userProvider.username ?? 'Chef';
      const avatarUrl = ''; 

      return CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: HomeHeader(userName: username, avatarUrl: avatarUrl),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Vertical Hero Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  HeroActionCard(
                    title: 'Upload Cookbook',
                    subtitle: 'Extract recipes from PDF',
                    icon: LucideIcons.fileText,
                    gradient: AppColors.freshStart,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  HeroActionCard(
                    title: 'Instagram',
                    subtitle: 'Save from Reels',
                    icon: LucideIcons.instagram,
                    gradient: AppColors.magicHour,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  HeroActionCard(
                    title: 'Mood Cooking',
                    subtitle: 'Cook by emotion',
                    icon: LucideIcons.smile,
                    gradient: AppColors.goldenHour,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionalCookingScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Today's Picks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today\'s Picks', style: AppTextStyles.headlineMedium),
                  if (matches.isNotEmpty)
                     Text('${matches.length} matches', style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: matches.isEmpty 
              ? _buildEmptyMatchState(context, userProvider)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: matches.length > 5 ? 5 : matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final recipe = match.recipe;
                    return RecipeCardHorizontal(
                      title: recipe.title,
                      imageUrl: "https://source.unsplash.com/random/800x600/?food,${recipe.title.replaceAll(' ', ',')}", 
                      time: "${recipe.cookTime}m",
                      calories: "350 kcal", 
                      matchPercentage: match.matchPercentage.round(),
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)));
                      },
                    );
                  },
                ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // From Your Fridge
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('From Your Fridge', style: AppTextStyles.headlineMedium),
                  if (userProvider.pantryList.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen()));
                      },
                      child: Text('See All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.freshMint)),
                    ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Fridge Items List
          SliverToBoxAdapter(
             child: SizedBox(
              height: 100,
              child: userProvider.pantryList.isEmpty
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                       _buildAddFridgeItem(context),
                    ],
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: (userProvider.pantryList.length > 5 ? 5 : userProvider.pantryList.length) + 1,
                    itemBuilder: (context, index) {
                      if (index == (userProvider.pantryList.length > 5 ? 5 : userProvider.pantryList.length)) {
                        return _buildAddFridgeItem(context);
                      }
                      
                      final item = userProvider.pantryList[index];
                      // Use safety checks for types
                      final name = item['name'] ?? 'Ingredient';
                      // Handle quantity which might be int or String
                      final rawQty = item['quantity'];
                      String qtyDisplay = '1';
                      if (rawQty != null) {
                        qtyDisplay = rawQty.toString();
                      }
                      
                      return _buildFridgeItem(name, qtyDisplay);
                    },
                  ),
             ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom Padding
        ],
      );
    });
  }

  Widget _buildEmptyMatchState(BuildContext context, UserProvider provider) {
      if (provider.pantryList.isEmpty) {
        return _buildEmptyStateCard(
          context, 
          "Your Fridge is Empty", 
          "Add ingredients to get suggestions",
          "Go to Pantry",
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen())),
        );
      }
      
      // If pantry has items but no matches, likely needs recipes
      return _buildEmptyStateCard(
        context,
        "No Matching Recipes",
        "We couldn't match your ingredients to any recipes.",
        "See All Recipes", 
        () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Try adding more varied ingredients!')));
        },
        secondaryAction: TextButton.icon(
          onPressed: () {
             _seedDummyRecipes(context);
          }, 
          icon: const Icon(LucideIcons.database),
          label: const Text("Debug: Add Dummy Recipes"),
        ),
      );
  }

  Widget _buildEmptyStateCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    String btnText, 
    VoidCallback onBtnTap,
    {Widget? secondaryAction}
  ) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.slate.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.chefHat, size: 48, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
             ElevatedButton(
                onPressed: onBtnTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent, 
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(btnText),
             ),
             if (secondaryAction != null) ...[
               const SizedBox(height: 8),
               secondaryAction,
             ]
          ],
        ),
      );
  }

  void _seedDummyRecipes(BuildContext context) {
    // Quick seeder for MVP testing
    final mockRecipes = [
      {
        'title': 'Tomato Omelette',
        'ingredients': ['Eggs', 'Tomatoes', 'Salt', 'Pepper'],
        'cookTime': 10,
        'difficulty': 'Easy',
        'source': 'manual'
      },
      {
        'title': 'Cheese Sandwich',
        'ingredients': ['Bread', 'Cheese', 'Butter'],
        'cookTime': 5,
        'difficulty': 'Easy',
        'source': 'manual'
      },
      {
        'title': 'Pancakes',
        'ingredients': ['Milk', 'Flour', 'Eggs', 'Sugar'],
        'cookTime': 20,
        'difficulty': 'Medium',
        'source': 'manual'
      }
    ];

    int added = 0;
    for (var r in mockRecipes) {
       FirestoreService().saveRecipe(r);
       added++;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $added recipes! Restart app to sync.')));
  }

  Widget _buildFridgeItem(String name, String quantity) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
         border: Border.all(color: AppColors.slate.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
             padding: const EdgeInsets.all(8),
             decoration: const BoxDecoration(
               color: AppColors.wash,
               shape: BoxShape.circle,
             ),
             child: const Icon(LucideIcons.carrot, color: AppColors.warmPeach, size: 20),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name, 
              style: AppTextStyles.labelMedium,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Text('$quantity items', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAddFridgeItem(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen())),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.freshMint.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.freshMint.withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(LucideIcons.plus, color: AppColors.freshMint),
             SizedBox(height: 4),
             Text("Add", style: TextStyle(color: AppColors.freshMint, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
