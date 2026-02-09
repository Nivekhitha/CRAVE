import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../providers/theme_provider.dart';

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
      color: Theme.of(context).scaffoldBackgroundColor, // Use theme background
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
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'CRAVE',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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
              // Theme Toggle Button
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildIconBtn(
                    context,
                    themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                    () => themeProvider.toggleTheme(),
                  );
                },
              ),
              const SizedBox(width: 8),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
