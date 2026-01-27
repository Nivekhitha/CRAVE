import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../grocery/grocery_screen.dart';
import '../match/match_screen.dart';
import '../pantry/pantry_screen.dart';
import '../profile/profile_screen.dart';
import '../add_recipe/add_recipe_options_screen.dart';
import '../emotional_cooking/emotional_cooking_screen.dart';
import '../cooking_journey/cooking_journey_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeView(),
    const MatchScreen(),
    const SizedBox(), // Placeholder for Add
    const GroceryScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddRecipeOptionsScreen()));
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 40, color: AppColors.primary),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Grocery'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final matches = userProvider.recipeMatches;
      final topMatch = matches.isNotEmpty ? matches.first : null;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getGreeting(), style: AppTextStyles.titleLarge),
                        Text('Ready to cook something?',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Today's Suggestion
            Text('Today\'s Suggestion', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),

            if (topMatch != null)
              _RecipeSuggestionCard(match: topMatch)
            else
              _EmptyFridgeCard(onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PantryScreen()));
              }),

            const SizedBox(height: 32),

            // Quick Actions
            Text('Quick Actions', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.mood,
              title: 'Emotional Foodie',
              subtitle: 'Cook based on your mood',
              color: Colors.purple.shade50,
              iconColor: Colors.purple,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EmotionalCookingScreen()));
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.emoji_events,
              title: 'Your Journey',
              subtitle: 'Track streaks & stats',
              color: Colors.orange.shade50,
              iconColor: Colors.orange,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CookingJourneyScreen()));
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.kitchen,
              title: 'Add Fridge Items',
              subtitle: 'Update your current stock',
              color: AppColors.surface,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PantryScreen()));
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.menu_book,
              title: 'Add Recipe',
              subtitle: 'Save a new meal idea',
              color: AppColors.surface,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddRecipeOptionsScreen()));
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.shopping_cart,
              title: 'Grocery List',
              subtitle: 'Items you need for recipes',
              color: AppColors.surface,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GroceryScreen()));
              },
            ),
            const SizedBox(height: 32),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: AppTextStyles.titleMedium),
                Text('See All',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _ActivityItem(
                      text: 'Cooked Spicy Ramen yesterday',
                      color: AppColors.primary),
                  SizedBox(height: 12),
                  _ActivityItem(
                      text: 'Milk expires in 2 days', color: Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 80), // Bottom padding for nav bar
          ],
        ),
      );
    });
  }
}

class _RecipeSuggestionCard extends StatelessWidget {
  final dynamic match;

  const _RecipeSuggestionCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final recipe = match.recipe;
    final percentage = match.matchPercentage.round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 60,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMatchColor(percentage),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percentage% Match with your fridge',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What can I cook today?',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  recipe.title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text('${recipe.cookTime} m',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.bolt, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text('Easy',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipe: recipe)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Text('View Recipe',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: Colors.white)),
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

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return AppColors.primary;
    if (percentage >= 50) return Colors.orange;
    return Colors.grey;
  }
}

class _EmptyFridgeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyFridgeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.kitchen, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Fridge is Empty!",
                      style: AppTextStyles.labelLarge),
                  Text("Add ingredients to get suggestions.",
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor ?? AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.textPrimary)),
                      Text(subtitle,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String text;
  final Color color;

  const _ActivityItem({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(text,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}
