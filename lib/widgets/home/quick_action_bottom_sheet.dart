import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../screens/add_recipe/add_recipe_options_screen.dart';
import '../../screens/pantry/pantry_screen.dart';
import '../../screens/grocery/grocery_screen.dart';

class QuickActionBottomSheet extends StatelessWidget {
  const QuickActionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Text(
            'Quick Actions',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 24),

          _ActionItem(
             icon: LucideIcons.chefHat,
             title: 'Add New Recipe',
             subtitle: 'Scan, Paste Link, or Create',
             color: AppColors.freshMint,
             onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeOptionsScreen()));
             }
          ),
          
          const SizedBox(height: 16),

          _ActionItem(
             icon: LucideIcons.refrigerator,
             title: 'Update Fridge',
             subtitle: 'Manage pantry ingredients',
             color: Colors.blueAccent,
             onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen()));
             }
          ),

          const SizedBox(height: 16),

          _ActionItem(
             icon: LucideIcons.shoppingCart,
             title: 'Grocery List',
             subtitle: 'Check what you need',
             color: Colors.orangeAccent,
             onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GroceryScreen()));
             }
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
             )
          ]
        ),
        child: Row(
          children: [
             Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                   color: color.withOpacity(0.1),
                   shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
             ),
             const SizedBox(width: 16),
             Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
                      Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate)),
                   ],
                ),
             ),
             const Icon(Icons.chevron_right, color: AppColors.slate),
          ],
        ),
      ),
    );
  }
}
