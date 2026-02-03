import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../widgets/premium/premium_gate.dart';

import 'package:provider/provider.dart';
import '../../services/journal_service.dart';

class NutritionDashboardScreen extends StatelessWidget {
  const NutritionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... header ...
    return PremiumGate(
      featureId: 'nutrition_insights',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Nutrition Insights", style: AppTextStyles.headlineMedium),
          centerTitle: true,
          leading: IconButton(
             icon: const Icon(Icons.arrow_back_ios, color: AppColors.charcoal, size: 20),
             onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<JournalService>(
          builder: (context, journal, child) {
             final protein = journal.todayProtein;
             final carbs = journal.todayCarbs;
             final fats = journal.todayFats;
             
             const proteinGoal = 150.0;
             const carbsGoal = 250.0;
             const fatsGoal = 70.0;

             return SingleChildScrollView(
               padding: const EdgeInsets.all(24),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Time Filter
                     Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.grey.shade200)
                        ),
                        child: Row(
                           children: [
                              _buildFilterTab("Today", true),
                              _buildFilterTab("Week", false),
                              _buildFilterTab("Month", false),
                           ],
                        ),
                     ),

                     // Macro Overview
                     Text("Macronutrients", style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                     const SizedBox(height: 16),
                     Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(24),
                           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
                        ),
                        child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                              _buildMacroRing("Protein", (protein / proteinGoal).clamp(0.0, 1.0), const Color(0xFF2D5A46), protein.toInt(), proteinGoal.toInt()),
                              _buildMacroRing("Carbs", (carbs / carbsGoal).clamp(0.0, 1.0), const Color(0xFFFFD54F), carbs.toInt(), carbsGoal.toInt()),
                              _buildMacroRing("Fats", (fats / fatsGoal).clamp(0.0, 1.0), const Color(0xFFB39DDB), fats.toInt(), fatsGoal.toInt()),
                           ],
                        ),
                     ),
                 
                 const SizedBox(height: 32),
                 
                 // Micronutrients
                 Text("Micronutrients", style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                 const SizedBox(height: 16),
                 GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                       _buildNutrientCard("Iron", "80%", LucideIcons.atom,),
                       _buildNutrientCard("Calcium", "45%", LucideIcons.bone),
                       _buildNutrientCard("Vitamin C", "110%", LucideIcons.apple),
                       _buildNutrientCard("Fiber", "65%", LucideIcons.wheat),
                    ],
                 ),
                 
                 const SizedBox(height: 32),

                 // Hydration
                  Text("Hydration", style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                        gradient: AppColors.freshStart,
                        borderRadius: BorderRadius.circular(24),
                     ),
                     child: Row(
                        children: [
                           Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.2), 
                                 shape: BoxShape.circle
                              ),
                              child: const Icon(LucideIcons.droplets, color: Colors.white, size: 28),
                           ),
                           const SizedBox(width: 16),
                           const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text("1.5 Liters", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                 Text("Target: 2.5 L", style: TextStyle(color: Colors.white70)),
                              ],
                           ),
                           const Spacer(),
                           FloatingActionButton.small(
                              onPressed: () {},
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.add, color: AppColors.primary),
                           )
                        ],
                     ),
                  )
              ],
           ),
        );
      },
    ),
      ),
    );
  }
  
  // ... filter tab ...

  Widget _buildMacroRing(String label, double progress, Color color, int current, int goal) {
     return Column(
        children: [
           SizedBox(
              height: 80, width: 80,
              child: Stack(
                 alignment: Alignment.center,
                 children: [
                    CircularProgressIndicator(value: progress, color: color, strokeWidth: 8, backgroundColor: AppColors.wash),
                    Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold))
                 ],
              ),
           ),
           const SizedBox(height: 12),
           Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
           Text("${(goal - current)}g left", style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.slate))
        ],
      );
  }
  
  Widget _buildFilterTab(String text, bool isSelected) {
     return Expanded(
        child: Container(
           padding: const EdgeInsets.symmetric(vertical: 8),
           decoration: BoxDecoration(
              color: isSelected ? AppColors.charcoal : Colors.transparent,
              borderRadius: BorderRadius.circular(8)
           ),
           alignment: Alignment.center,
           child: Text(
              text, 
              style: TextStyle(
                 color: isSelected ? Colors.white : AppColors.slate, 
                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
           ),
        ),
     );
  }



  Widget _buildNutrientCard(String title, String val, IconData icon) {
     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4)]
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Icon(icon, color: AppColors.slate.withOpacity(0.5), size: 20),
              Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(val, style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                    Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate)),
                 ],
              )
           ],
        ),
     );
  }
}
