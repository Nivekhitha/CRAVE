import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';

class HomeHeaderRevamp extends StatelessWidget {
  final String userName;
  final String? avatarUrl;

  const HomeHeaderRevamp({
    super.key,
    required this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: AppColors.background, // Match screen background
      child: Row(
        children: [
          // Logo & Greeting
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/app_logo.png'), // Fallback if asset missing
                fit: BoxFit.cover,
              ),
            ),
            child: const Icon(Icons.restaurant_menu, color: AppColors.flameAmber), // Fallback icon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, $userName 👋',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'CRAVE',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconBtn(
                context, 
                Icons.favorite_border, 
                () => Navigator.pushNamed(context, '/favorites'), // Route needed
              ),
              const SizedBox(width: 8),
              _buildIconBtn(
                context, 
                Icons.logout, 
                () {
                   // Since this is a UI widget, we'll let the parent handle logout or just show dialog
                   // Ideally we pass a callback, but for now strict port
                   // Actually, let's keep it simple and just show a dialog or assume parent handling?
                   // No, let's trigger a sign out via a callback if needed, but for now just a placeholder action
                   // or standard auth signout if we have context.
                   // Let's leave it as a "Settings" or "Logout" button
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppColors.textPrimary),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
