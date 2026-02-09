import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class QuickActionGrid extends StatelessWidget {
  final int pantryCount;
  final int groceryCount;
  final int journalCount; // Replacing water with Journal stats if desired, or keep as navigation
  final VoidCallback onPantryTap;
  final VoidCallback onGroceryTap;
  final VoidCallback onPlannerTap;
  final VoidCallback onJournalTap;

  const QuickActionGrid({
    super.key,
    required this.pantryCount,
    required this.groceryCount,
    required this.journalCount, // e.g. recipes cooked
    required this.onPantryTap,
    required this.onGroceryTap,
    required this.onPlannerTap,
    required this.onJournalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildActionCard(
                context,
                icon: Icons.kitchen,
                color: const Color(0xFFD84315), // Deep orange-red
                label: 'Pantry',
                value: '$pantryCount items',
                onTap: onPantryTap,
              ),
              const SizedBox(width: 12),
              _buildActionCard(
                context,
                icon: Icons.shopping_cart,
                color: const Color(0xFF7BA47B), // Sage green (from palette)
                label: 'Grocery',
                value: '$groceryCount items',
                onTap: onGroceryTap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionCard(
                context,
                icon: Icons.calendar_today,
                color: const Color(0xFFD4654A), // Terracotta (from palette)
                label: 'Planner',
                value: 'Weekly',
                onTap: onPlannerTap,
              ),
              const SizedBox(width: 12),
              _buildActionCard(
                context,
                icon: Icons.book,
                color: const Color(0xFFC0392B), // Deep red
                label: 'Journal',
                value: '$journalCount cooked',
                onTap: onJournalTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
