import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../services/seed_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150'), // Placeholder
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
              Text('User Name', style: AppTextStyles.headlineMedium),
              Text('user@example.com', style: AppTextStyles.bodyMedium),
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
      ),
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
