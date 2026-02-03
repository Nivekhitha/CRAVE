import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import '../../widgets/cards/recipe_card_horizontal.dart'; // Reuse for style or create new

class DailyFoodJournalScreen extends StatelessWidget {
  const DailyFoodJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Today's Journal", style: AppTextStyles.headlineMedium),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.charcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendar, color: AppColors.charcoal),
            onPressed: () {
               // Show date picker
            },
          )
        ],
      ),
      body: Consumer<JournalService>(
        builder: (context, journal, child) {
          final entries = journal.todayEntries;
          
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
               _buildMealSection(context, "Breakfast", JournalMealType.breakfast, entries),
               const SizedBox(height: 24),
               _buildMealSection(context, "Lunch", JournalMealType.lunch, entries),
               const SizedBox(height: 24),
               _buildMealSection(context, "Dinner", JournalMealType.dinner, entries),
               const SizedBox(height: 24),
               _buildMealSection(context, "Snacks", JournalMealType.snack, entries),
               const SizedBox(height: 80), // Fab space
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           // Quick add generic
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Quick Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, String title, JournalMealType type, List<JournalEntry> allEntries) {
    final mealEntries = allEntries.where((e) => e.mealType == type).toList();
    final totalCals = mealEntries.fold(0, (sum, e) => sum + e.calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            Text("$totalCals kcal", style: AppTextStyles.labelMedium.copyWith(color: AppColors.slate)),
          ],
        ),
        const SizedBox(height: 12),
        if (mealEntries.isEmpty)
          _buildEmptyMealSlot(context, type)
        else
          ...mealEntries.map((e) => _buildEntryTile(e)).toList(),
          
        if (mealEntries.isNotEmpty)
           Padding(
             padding: const EdgeInsets.only(top: 12),
             child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                      children: [
                         const Icon(Icons.add, color: AppColors.primary, size: 18),
                         const SizedBox(width: 8),
                         Text("Add Food", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                      ],
                   ),
                ),
             ),
           )
      ],
    );
  }

  Widget _buildEmptyMealSlot(BuildContext context, JournalMealType type) {
    return GestureDetector(
      onTap: () {
         // Add meal
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid), // Dashed borders need custom painter
        ),
        child: Column(
           children: [
              Icon(LucideIcons.plusCircle, color: AppColors.primary.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text("Log $type", style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate)),
           ],
        ),
      ),
    );
  }

  Widget _buildEntryTile(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
           Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(8)),
              child: const Text("🥑", style: TextStyle(fontSize: 20)), // Dynamic based on food?
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(entry.name, style: AppTextStyles.labelMedium),
                   Text("1 serving", style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate))
                ],
             ),
           ),
           Text("${entry.calories}", style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}
