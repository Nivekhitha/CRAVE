import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../services/seed_data_service.dart';

import 'package:provider/provider.dart';
import '../../services/image_service.dart';
import '../../services/premium_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/premium/paywall_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final username = userProvider.username ?? 'Guest';
          final email = userProvider.user?.email ?? 'No email';
          final avatarUrl = ImageService().getUserAvatarUrl(username);
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                         CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(username, style: AppTextStyles.headlineMedium),
                      if (Provider.of<PremiumService>(context).isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.magicHour,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                  Text(email, style: AppTextStyles.bodyMedium),
                  
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('🔥', '${userProvider.cookingStreak} Day', 'Strom'),
                      _buildContainerDivider(),
                      _buildStatColumn('🍳', '${userProvider.recipesCooked}', 'Cooked'),
                      _buildContainerDivider(),
                      _buildStatColumn('📝', '12', 'Logged'), // Mock 'Logged' for now
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Upgrade Banner
                  if (!Provider.of<PremiumService>(context).isPremium)
                    GestureDetector(
                      onTap: () {
                         // Trigger paywall via premium gate or direct navigation
                         // For now, simple snackbar or navigate to Journal (which is gated)
                         // Or better, show Paywall modal directly
                         showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => PaywallView(
                               onUnlock: () async {
                                  try {
                                     await Provider.of<PremiumService>(context, listen: false).unlockPremium();
                                     Navigator.pop(context);
                                  } catch (e) {
                                     // Error handled in service
                                  }
                               },
                               isLoading: Provider.of<PremiumService>(context).isLoading,
                            )
                         );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.magicHour,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                             BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                          ]
                        ),
                        child: Row(
                          children: [
                             Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.star, color: Colors.white),
                             ),
                             const SizedBox(width: 16),
                             const Expanded(
                                child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                      Text("Upgrade to Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("Unlock AI Dietitian & unlimited recipes", style: TextStyle(color: Colors.white70, fontSize: 12))
                                   ],
                                ),
                             ),
                             const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),

              // Menu Options
              _ProfileOption(icon: Icons.person_outline, title: 'My Account', onTap: () {}),
              _ProfileOption(icon: Icons.favorite_border, title: 'Saved Recipes', onTap: () {}),
              _ProfileOption(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
              _ProfileOption(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
              _ProfileOption(
                icon: Icons.logout,
                title: 'Log Out',
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                },
                textColor: AppColors.error,
                iconColor: AppColors.error,
              ),

              const SizedBox(height: 32),
              // Developer Options
              Text('Developer Options', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              _ProfileOption(
                icon: Icons.cloud_upload_outlined,
                title: 'Seed Recipes (Dev Only)',
                onTap: () async {
                  try {
                     // Lazy import logic or direct usage if service file is imported
                     // For now, simpler to import at top
                     await SeedDataService().seedRecipes();
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Recipes seeded successfully!')));
                     }
                  } catch (e) {
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                     }
                  }
                },
                iconColor: Colors.purple,
              ),
            ],
          ),
        ),
      );
    },
  ),
);
  }

  Widget _buildStatColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate)),
      ],
    );
  }

  Widget _buildContainerDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(color: textColor ?? AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
