import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../grocery/grocery_screen.dart';
import '../match/match_screen.dart';
import '../pantry/pantry_screen.dart';
import '../profile/profile_screen.dart';
import '../add_recipe/add_recipe_options_screen.dart';

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
    const GroceryScreen(), // Replaced Pantry with Grocery for Bottom Nav
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Navigate to Add Recipe Options Screen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeOptionsScreen()));
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
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: AppColors.primary), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Grocery'),
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

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/100'), // Placeholder
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, User 👋', style: AppTextStyles.titleLarge),
                      Text('Ready to cook something?', style: AppTextStyles.bodySmall),
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
          Container(
            width: double.infinity,
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
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Container(
                        height: 180,
                        color: Colors.grey[300], // Image placeholder light
                        child: Center(child: Icon(Icons.fastfood, color: Colors.grey[500], size: 50)),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '90% Match with your fridge',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What can I cook today?',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                      ),
                      Text(
                        'Creamy Pesto Pasta',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text('15 min', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.bolt, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text('Easy', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                            ],
                          ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeDetailScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: Text('View Recipe', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          Text('Quick Actions', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _QuickActionCard(
            icon: Icons.kitchen,
            title: 'Add Fridge Items',
            subtitle: 'Update your current stock',
            color: AppColors.surface,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen()));
            },
          ),
          const SizedBox(height: 12),
          _QuickActionCard(
            icon: Icons.menu_book,
            title: 'Add Recipe',
            subtitle: 'Save a new meal idea',
            color: AppColors.surface,
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeOptionsScreen()));
            },
          ),
          const SizedBox(height: 12),
          _QuickActionCard(
            icon: Icons.shopping_cart,
            title: 'Grocery List',
            subtitle: 'Items you need for recipes',
            color: AppColors.surface,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GroceryScreen()));
            },
          ),
          const SizedBox(height: 32),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: AppTextStyles.titleMedium),
              Text('See All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
             ),
             child: Column(
               children: [
                 _ActivityItem(text: 'Cooked Spicy Ramen yesterday', color: AppColors.primary),
                 const SizedBox(height: 12),
                 _ActivityItem(text: 'Milk expires in 2 days', color: Colors.orange),
               ],
             ),
          ),
          const SizedBox(height: 80), // Bottom padding for nav bar
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                      Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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
        Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}
