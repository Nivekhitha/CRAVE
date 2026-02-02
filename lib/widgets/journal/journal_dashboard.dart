import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

class JournalDashboard extends StatelessWidget {
  const JournalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today', style: AppTextStyles.headlineMedium),
              const Icon(LucideIcons.calendar, color: AppColors.slate),
            ],
          ),
          const SizedBox(height: 24),

          // Calorie Ring Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.freshStart,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.freshMint.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 8,
                      ),
                      const Text('1450', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calories Eaten', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Goal: 2000 kcal', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Meals Section
          Text('Meals', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          
          _buildMealCard('Breakfast', 'Oatmeal & Berries', '350 kcal', LucideIcons.coffee),
          const SizedBox(height: 16),
          _buildMealCard('Lunch', 'Chicken Salad', '450 kcal', LucideIcons.utensils),
          const SizedBox(height: 16),
          _buildMealCard('Dinner', 'Add Meal', '', LucideIcons.plus, isAdd: true),
        ],
      ),
    );
  }

  Widget _buildMealCard(String title, String subtitle, String calories, IconData icon, {bool isAdd = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isAdd ? Border.all(color: AppColors.slate.withOpacity(0.2), style: BorderStyle.solid) : null,
        boxShadow: isAdd ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAdd ? AppColors.wash : AppColors.freshMint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isAdd ? AppColors.slate : AppColors.freshMint, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                if (subtitle.isNotEmpty) Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (calories.isNotEmpty)
            Text(calories, style: AppTextStyles.labelMedium.copyWith(color: AppColors.slate)),
        ],
      ),
    );
  }
}
