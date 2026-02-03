import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../widgets/premium/premium_gate.dart';

class WeeklyMealPlannerScreen extends StatefulWidget {
  const WeeklyMealPlannerScreen({super.key});

  @override
  State<WeeklyMealPlannerScreen> createState() => _WeeklyMealPlannerScreenState();
}

class _WeeklyMealPlannerScreenState extends State<WeeklyMealPlannerScreen> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'meal_planning',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Meal Planner", style: AppTextStyles.headlineMedium),
          centerTitle: true,
          leading: IconButton(
             icon: const Icon(Icons.arrow_back_ios, color: AppColors.charcoal, size: 20),
             onPressed: () => Navigator.pop(context),
          ),
          actions: [
             IconButton(
                icon: const Icon(LucideIcons.sparkles, color: AppColors.purpleX11),
                onPressed: () {
                   // Trigger AI Generator
                },
             )
          ],
        ),
        body: Column(
           children: [
              _buildWeekStrip(),
              Expanded(
                 child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          _buildMealSlot("Breakfast", "08:00 AM"),
                          const SizedBox(height: 16),
                          _buildMealSlot("Lunch", "01:00 PM"),
                          const SizedBox(height: 16),
                          _buildMealSlot("Dinner", "07:30 PM"),
                          const SizedBox(height: 16),
                          _buildMealSlot("Snacks", "Anytime"),
                       ],
                    ),
                 ),
              )
           ],
        ),
        floatingActionButton: FloatingActionButton.extended(
           onPressed: () {},
           backgroundColor: AppColors.freshMint,
           icon: const Icon(Icons.check, color: Colors.white),
           label: const Text("Save Plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildWeekStrip() {
    return Container(
       color: Colors.white,
       padding: const EdgeInsets.symmetric(vertical: 16),
       child: SizedBox(
          height: 80,
          child: ListView.builder(
             scrollDirection: Axis.horizontal,
             padding: const EdgeInsets.symmetric(horizontal: 16),
             itemCount: _days.length,
             itemBuilder: (context, index) {
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                   onTap: () => setState(() => _selectedDayIndex = index),
                   child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                         color: isSelected ? AppColors.primary : AppColors.wash,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent)
                      ),
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                            Text(_days[index], style: TextStyle(color: isSelected ? Colors.white : AppColors.slate, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${10 + index}", style: TextStyle(color: isSelected ? Colors.white : AppColors.charcoal, fontWeight: FontWeight.bold, fontSize: 18))
                         ],
                      ),
                   ),
                );
             },
          ),
       ),
    );
  }

  Widget _buildMealSlot(String title, String time) {
     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Row(
                       children: [
                          Icon(LucideIcons.clock, size: 16, color: AppColors.slate),
                          const SizedBox(width: 8),
                          Text(time, style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate)),
                       ],
                    ),
                    Icon(Icons.more_horiz, color: AppColors.slate)
                 ],
              ),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              
              // Empty Slot
              GestureDetector(
                 onTap: () {},
                 child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                       color: AppColors.wash,
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.grey.shade200)
                    ),
                    child: Center(
                       child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(LucideIcons.plus, size: 18, color: AppColors.slate),
                             const SizedBox(width: 8),
                             Text("Add Meal", style: TextStyle(color: AppColors.slate, fontWeight: FontWeight.w600)),
                          ],
                       ),
                    ),
                 ),
              )
           ],
        ),
     );
  }
}
