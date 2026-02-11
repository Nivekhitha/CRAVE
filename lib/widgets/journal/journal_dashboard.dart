import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import '../../providers/user_provider.dart';
import '../../services/image_service.dart';
import '../../screens/journal/daily_food_journal_screen.dart';
import '../../screens/dietitian/ai_dietitian_chat_screen.dart';
import '../../screens/journal/weekly_meal_planner_screen.dart';
import '../../screens/nutrition/nutrition_dashboard_screen.dart';

class JournalDashboard extends StatelessWidget {
  const JournalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalService>(
      builder: (context, journal, child) {
        final calories = journal.todayCalories;
        final goal = 2000;
        final progress = (calories / goal).clamp(0.0, 1.0);
        final remaining = (goal - calories).clamp(0, goal);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Date
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text("Journal", style: AppTextStyles.headlineMedium),
                          const SizedBox(height: 4),
                          Text("Today's Nourishment 👋", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warmPeach)),
                       ],
                    ),
                    IconButton(
                       icon: const Icon(LucideIcons.settings, color: AppColors.slate),
                       onPressed: () {},
                    )
                 ],
              ),
              
              const SizedBox(height: 24),

              // Main Calorie Ring Card
              Container(
                 padding: const EdgeInsets.symmetric(vertical: 32),
                 decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                       BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                       )
                    ]
                 ),
                 child: Column(
                    children: [
                       // Ring
                       SizedBox(
                          height: 200,
                          width: 200,
                          child: Stack(
                             alignment: Alignment.center,
                             children: [
                                SizedBox(
                                   width: 180, 
                                   height: 180,
                                   child: CircularProgressIndicator(
                                      value: progress, 
                                      strokeWidth: 16,
                                      backgroundColor: AppColors.wash,
                                      valueColor: const AlwaysStoppedAnimation(Color(0xFF2D5A46)),
                                      strokeCap: StrokeCap.round,
                                   ),
                                ),
                                Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                      Text("$remaining", 
                                         style: AppTextStyles.headlineLarge.copyWith(
                                            fontSize: 48, 
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary
                                         )
                                      ),
                                      Text("KCAL LEFT TODAY", 
                                         style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.slate,
                                            letterSpacing: 1.2
                                         )
                                      ),
                                   ],
                                )
                             ],
                          ),
                       ),
                       const SizedBox(height: 32),
                       
                       // Action Buttons
                       Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             ElevatedButton(
                                onPressed: () {
                                   Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyFoodJournalScreen()));
                                },
                                style: ElevatedButton.styleFrom(
                                   backgroundColor: const Color(0xFF2D5A46), // Dark Green
                                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("Log Meal", style: TextStyle(color: Colors.white)),
                             ),
                             const SizedBox(width: 16),
                             ElevatedButton(
                                onPressed: () {
                                   Navigator.push(context, MaterialPageRoute(builder: (_) => const AIDietitianChatScreen()));
                                },
                                style: ElevatedButton.styleFrom(
                                   backgroundColor: const Color(0xFFE8F3EB), // Light Green
                                   elevation: 0,
                                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("Ask Dietitian", style: TextStyle(color: Color(0xFF2D5A46))),
                             ),
                          ],
                       )
                    ],
                 ),
              ),

              const SizedBox(height: 32),

              // User Greeting Strip
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final username = userProvider.username ?? 'Chef';
                  final avatarUrl = ImageService().getUserAvatarUrl(username);
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFF0F5)], // White to light pink
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100)
                    ),
                    child: Row(
                        children: [
                          CircleAvatar(
                              backgroundImage: NetworkImage(avatarUrl),
                              radius: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text("Good afternoon $username 🌿", style: AppTextStyles.labelMedium),
                                    Text("Ready to plan something fresh today?", style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate))
                                ],
                              ),
                          )
                        ],
                    ),
                  );
                }
              ),
              
              const SizedBox(height: 32),

              // Today's Meals Header
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text("Today's Meals", style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                    Text("View All", style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF2D5A46))),
                 ],
              ),
              
              const SizedBox(height: 16),

              // Horizontal Meal List (Dynamic)
              SizedBox(
                 height: 160,
                 child: journal.todayEntries.isEmpty 
                 ? Center(child: Text("No meals logged yet", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate)))
                 : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: journal.todayEntries.length,
                    itemBuilder: (context, index) {
                       final entry = journal.todayEntries[index];
                       String emoji = "🍽️";
                       if (entry.mealType == JournalMealType.breakfast) emoji = "🥐";
                       if (entry.mealType == JournalMealType.lunch) emoji = "🥗";
                       if (entry.mealType == JournalMealType.dinner) emoji = "🍲";
                       if (entry.mealType == JournalMealType.snack) emoji = "🍎";

                       return _buildMealCard(
                          entry.mealType.name.toUpperCase(), 
                          "${entry.calories} kcal", 
                          emoji, 
                          isCompleted: true
                       );
                    },
                 ),
              ),

              const SizedBox(height: 32),
              
              // "Your Week"
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text("Your Week", style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                    GestureDetector(
                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyMealPlannerScreen())),
                       child: Text("Plan Meals", style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF2D5A46))),
                    )
                 ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyMealPlannerScreen())),
                 child: _buildWeekRow(),
              ),

              const SizedBox(height: 32),
              
              // "Today's Balance"
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text("Today's Balance", style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                    GestureDetector(
                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionDashboardScreen())),
                       child: Text("Full Insights", style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF2D5A46))),
                    )
                 ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionDashboardScreen())),
                 child: _buildBalanceCarousels(journal),
              ),
              
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        );
      }
    );
  }

  Widget _buildMealCard(String title, String subtitle, String emoji, {bool isCompleted = false, bool isPending = false}) {
     return Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: Colors.grey.shade100),
           boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
           ]
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate)),
                 ],
              ),
              Align(
                 alignment: Alignment.centerRight,
                 child: Icon(
                    isCompleted ? Icons.check_circle : (isPending ? Icons.add_circle_outline : Icons.circle_outlined),
                    size: 20,
                    color: isCompleted ? AppColors.freshMint : AppColors.slate.withOpacity(0.3)
                 ),
              )
           ],
        ),
     );
  }

  Widget _buildWeekRow() {
     // Static week for demo logic
     final days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
     final now = DateTime.now();
     // Generate dates around today
     final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
     
     return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(24),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = date.day == now.day && date.month == now.month;
              
              return Column(
                 children: [
                    Text(days[index], style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.slate)),
                    const SizedBox(height: 8),
                    Container(
                       width: 32, height: 32,
                       alignment: Alignment.center,
                       decoration: BoxDecoration(
                          color: isToday ? const Color(0xFF2D5A46) : Colors.transparent,
                          shape: BoxShape.circle,
                       ),
                       child: Text(
                          date.day.toString(),
                          style: TextStyle(
                             color: isToday ? Colors.white : AppColors.textPrimary,
                             fontWeight: FontWeight.bold
                          ),
                       ),
                    )
                 ],
              );
           }),
        ),
     );
  }

  Widget _buildBalanceCarousels(JournalService journal) {
     final protein = journal.todayProtein;
     final carbs = journal.todayCarbs;
     final fats = journal.todayFats;

     // Mock Goals
     const proteinGoal = 150;
     const carbsGoal = 250;
     const fatsGoal = 70;

     return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(24),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
        ),
        child: Row(
           children: [
              // Macro Chart
              Expanded(
                 child: SizedBox(
                    height: 120,
                    child: Stack(
                       alignment: Alignment.center,
                       children: [
                          CircularProgressIndicator(value: (carbs/carbsGoal).clamp(0,1), backgroundColor: AppColors.wash, color: const Color(0xFFFFD54F), strokeWidth: 12),
                          CircularProgressIndicator(value: (protein/proteinGoal).clamp(0,1), backgroundColor: Colors.transparent, color: const Color(0xFF2D5A46), strokeWidth: 12),
                          CircularProgressIndicator(value: (fats/fatsGoal).clamp(0,1), backgroundColor: Colors.transparent, color: const Color(0xFFB39DDB), strokeWidth: 12),
                          const Icon(Icons.favorite, color: Color(0xFFFFCCBC))
                       ],
                    ),
                 ),
              ),
              // Water
              Expanded(
                 child: Column(
                    children: [
                        SizedBox(
                           height: 60, width: 60,
                           child: CircularProgressIndicator(value: 0.8, backgroundColor: AppColors.wash, color: Colors.cyanAccent, strokeWidth: 6),
                        ),
                        const SizedBox(height: 8),
                        Text("1.5 L", style: AppTextStyles.labelLarge),
                    ],
                 ),
              )
           ],
        ),
     );
  }
}
