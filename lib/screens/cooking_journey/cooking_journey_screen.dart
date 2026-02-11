import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class CookingJourneyScreen extends StatelessWidget {
  const CookingJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Your Cooking Journey', style: AppTextStyles.titleLarge),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Soft gradient using primary color
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        '${userProvider.cookingStreak}-Day Cooking Streak!',
                        style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re on a roll, keep it going!',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Weekly Stats
            Text('Weekly Stats', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.restaurant,
                    title: 'Recipes Cooked',
                    value: '${userProvider.recipesCooked}',
                    subtitle: '+20% this week',
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MoneySavedCard(amount: userProvider.moneySaved),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Activity Level
            Text('Activity Level', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Activity Level', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('High 🔥', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text('Goal', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                           const SizedBox(height: 4),
                           Text('15 meals / week', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                   const SizedBox(height: 24),
                   // Mock Weekly Indicator
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                       final bool isActive = ['M', 'W', 'T', 'S'].contains(day); // Mock active days
                       return Column(
                         children: [
                           Container(
                             width: 8,
                             height: 32,
                             decoration: BoxDecoration(
                               color: isActive ? AppColors.primary : Colors.grey.shade200,
                               borderRadius: BorderRadius.circular(4),
                             ),
                           ),
                           const SizedBox(height: 8),
                           Text(day, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey)),
                         ],
                       );
                     }).toList(),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Achievements
            Text('Recent Achievements', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AchievementBadge(icon: Icons.emoji_events, color: Colors.amber, label: 'Master Chef'),
                _AchievementBadge(icon: Icons.recycling, color: Colors.green, label: 'Zero Waste'),
                _AchievementBadge(icon: Icons.savings, color: Colors.blue, label: 'Money Saver'),
              ],
            ),
             const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color iconColor;

  const _StatCard({
    required this.icon, 
    required this.title, 
    required this.value, 
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.green.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: Colors.green, fontSize: 10)),
           ),
        ],
      ),
    );
  }
}

class _MoneySavedCard extends StatelessWidget {
  final double amount;
  
  const _MoneySavedCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 16),
          Text('\$${amount.toStringAsFixed(2)}', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Money Saved', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Estimated savings', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _AchievementBadge({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(color: color.withOpacity(0.2), width: 4),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 12),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}
