import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../services/premium_service.dart';
import '../home/home_screen.dart';
import '../discovery/discovery_screen.dart';
import '../journal/journal_hub_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/premium/premium_gate.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<NavigationTab> _tabs = [
    NavigationTab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      screen: const HomeScreen(),
    ),
    NavigationTab(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Discovery',
      screen: const DiscoveryScreen(),
    ),
    NavigationTab(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'Journal',
      screen: const JournalHubScreen(),
      isPremium: true,
      featureId: 'journal',
      premiumTitle: 'Food Journal',
      premiumDescription: 'Track your meals and nutrition with detailed insights',
    ),
    NavigationTab(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      screen: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _tabs.map((tab) {
          if (tab.isPremium) {
            return PremiumGate(
              featureId: tab.featureId!,
              title: tab.premiumTitle,
              description: tab.premiumDescription,
              child: tab.screen,
            );
          }
          return tab.screen;
        }).toList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left tabs
              _buildNavItem(0),
              _buildNavItem(1),
              
              // FAB space
              const SizedBox(width: 64),
              
              // Right tabs
              _buildNavItem(2),
              _buildNavItem(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final tab = _tabs[index];
    final isActive = _currentIndex == index;
    
    return Consumer<PremiumService>(
      builder: (context, premiumService, _) {
        final canAccess = !tab.isPremium || premiumService.canUseFeature('journal');
        
        return GestureDetector(
          onTap: () => _onTabTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Icon(
                      isActive ? tab.activeIcon : tab.icon,
                      color: isActive 
                          ? AppColors.primary 
                          : (canAccess ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5)),
                      size: 24,
                    ),
                    
                    // Premium badge
                    if (tab.isPremium && !canAccess)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive 
                        ? AppColors.primary 
                        : (canAccess ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5)),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _onTabTapped(int index) {
    final tab = _tabs[index];
    
    // Check premium access for premium tabs
    if (tab.isPremium) {
      final premiumService = Provider.of<PremiumService>(context, listen: false);
      if (!premiumService.canUseFeature('journal')) {
        // Show paywall instead of navigating
        return;
      }
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showAddModal() {
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _AddActionModal(),
    );
  }
}

class NavigationTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;
  final bool isPremium;
  final String? featureId;
  final String? premiumTitle;
  final String? premiumDescription;

  NavigationTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
    this.isPremium = false,
    this.featureId,
    this.premiumTitle,
    this.premiumDescription,
  });
}

class _AddActionModal extends StatelessWidget {
  const _AddActionModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Quick Actions',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.upload_file,
                    title: 'Upload Recipe',
                    subtitle: 'PDF or URL',
                    color: AppColors.primary,
                    onTap: () => _navigateToUploadRecipe(context),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.edit,
                    title: 'Manual Recipe',
                    subtitle: 'Create from scratch',
                    color: AppColors.accent,
                    onTap: () => _navigateToManualRecipe(context),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.kitchen,
                    title: 'Update Fridge',
                    subtitle: 'Manage pantry',
                    color: Colors.green,
                    onTap: () => _navigateToUpdateFridge(context),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Grocery List',
                    subtitle: 'Add items',
                    color: Colors.orange,
                    onTap: () => _navigateToGroceryList(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToUploadRecipe(BuildContext context) {
    Navigator.pop(context); // Close modal
    Navigator.pushNamed(context, AppRoutes.addRecipeOptions);
  }

  void _navigateToManualRecipe(BuildContext context) {
    Navigator.pop(context); // Close modal
    Navigator.pushNamed(context, AppRoutes.addRecipe);
  }

  void _navigateToUpdateFridge(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/pantry');
  }

  void _navigateToGroceryList(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/grocery');
  }
}