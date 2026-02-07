import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/journal_service.dart';
import '../../services/premium_service.dart';
import '../../widgets/premium/premium_gate.dart';
import '../../models/journal_entry.dart';
import 'daily_food_journal_screen.dart';
import 'weekly_meal_planner_screen.dart';
import '../nutrition/nutrition_dashboard_screen.dart';
import '../dietitian/ai_dietitian_chat_screen.dart';
import 'dart:math' as math;

class JournalHubScreen extends StatefulWidget {
  const JournalHubScreen({super.key});

  @override
  State<JournalHubScreen> createState() => _JournalHubScreenState();
}

class _JournalHubScreenState extends State<JournalHubScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
    
    // Initialize journal service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalService>(context, listen: false).init();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JournalGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildCaloriesRingHero(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildTodaysMeals(),
                    const SizedBox(height: 32),
                    _buildWeeklyPreview(),
                    const SizedBox(height: 32),
                    _buildNutritionSnapshot(),
                    const SizedBox(height: 32),
                    _buildAIDietitianPreview(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<PremiumService>(
      builder: (context, premiumService, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Journal',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your nutrition journey',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (premiumService.isPremium.value)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCaloriesRingHero() {
    return Consumer<JournalService>(
      builder: (context, journalService, _) {
        final todayCalories = journalService.todayCalories;
        const targetCalories = 2000; // This could be user-configurable
        final progress = (todayCalories / targetCalories).clamp(0.0, 1.0);
        
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              // Calories Ring
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background ring
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.surface.withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Progress ring
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        tween: Tween(begin: 0.0, end: progress),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 12,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$todayCalories',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        Text(
                          'of $targetCalories cal',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCaloriesStatusColor(progress).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getCaloriesStatusText(progress),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getCaloriesStatusColor(progress),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Macros summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacroSummary(
                    'Protein',
                    '${journalService.todayProtein}g',
                    AppColors.primary,
                  ),
                  _buildMacroSummary(
                    'Carbs',
                    '${journalService.todayCarbs}g',
                    AppColors.accent,
                  ),
                  _buildMacroSummary(
                    'Fats',
                    '${journalService.todayFats}g',
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroSummary(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle,
                title: 'Log Meal',
                subtitle: 'Add food to journal',
                color: AppColors.primary,
                onTap: () => _navigateToLogMeal(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.psychology,
                title: 'Ask Dietitian',
                subtitle: 'Get nutrition advice',
                color: AppColors.accent,
                onTap: () => _navigateToAIDietitian(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMeals() {
    return Consumer<JournalService>(
      builder: (context, journalService, _) {
        final todayEntries = journalService.todayEntries;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Meals',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToLogMeal(),
                  child: Text(
                    'View All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (todayEntries.isEmpty)
              _buildEmptyMealsState()
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayEntries.length,
                  itemBuilder: (context, index) {
                    final entry = todayEntries[index];
                    return _buildMealCard(entry);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyMealsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No meals logged today',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your nutrition by logging your first meal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToLogMeal(),
            icon: const Icon(Icons.add),
            label: const Text('Log First Meal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(JournalEntry entry) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMealTypeColor(entry.mealType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMealTypeIcon(entry.mealType),
                  color: _getMealTypeColor(entry.mealType),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getMealTypeName(entry.mealType),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.name,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${entry.calories} cal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Week',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToWeeklyPlanner(),
              child: Text(
                'Plan Week',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWeekStrip(),
      ],
    );
  }

  Widget _buildWeekStrip() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekStart.add(Duration(days: index));
          final isToday = date.day == now.day && 
                         date.month == now.month && 
                         date.year == now.year;
          
          return _buildDayCard(date, isToday);
        },
      ),
    );
  }

  Widget _buildDayCard(DateTime date, bool isToday) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.surface,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayNames[date.weekday - 1],
            style: AppTextStyles.labelSmall.copyWith(
              color: isToday ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: AppTextStyles.titleMedium.copyWith(
              color: isToday ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isToday ? Colors.white : AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSnapshot() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nutrition Snapshot',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToNutritionDashboard(),
                child: Text(
                  'View Details',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Macro pie chart placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildNutritionRow('Hydration', '6/8 glasses', Icons.water_drop, Colors.blue),
                    const SizedBox(height: 8),
                    _buildNutritionRow('Fiber', '18/25g', Icons.grass, Colors.green),
                    const SizedBox(height: 8),
                    _buildNutritionRow('Vitamins', '4/6 types', Icons.medication, Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAIDietitianPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Dietitian',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Your personal nutrition coach',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Today\'s Tip',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re doing great with protein intake! Try adding more colorful vegetables to boost your vitamin intake.',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToAIDietitian(),
              icon: const Icon(Icons.chat),
              label: const Text('Chat with Dietitian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getCaloriesStatusColor(double progress) {
    if (progress < 0.5) return Colors.orange;
    if (progress < 0.9) return AppColors.primary;
    if (progress <= 1.1) return Colors.green;
    return Colors.red;
  }

  String _getCaloriesStatusText(double progress) {
    if (progress < 0.5) return 'Keep going!';
    if (progress < 0.9) return 'On track';
    if (progress <= 1.1) return 'Perfect!';
    return 'Over target';
  }

  Color _getMealTypeColor(JournalMealType mealType) {
    switch (mealType) {
      case JournalMealType.breakfast:
        return Colors.orange;
      case JournalMealType.lunch:
        return Colors.green;
      case JournalMealType.dinner:
        return Colors.blue;
      case JournalMealType.snack:
        return Colors.purple;
    }
  }

  IconData _getMealTypeIcon(JournalMealType mealType) {
    switch (mealType) {
      case JournalMealType.breakfast:
        return Icons.free_breakfast;
      case JournalMealType.lunch:
        return Icons.lunch_dining;
      case JournalMealType.dinner:
        return Icons.dinner_dining;
      case JournalMealType.snack:
        return Icons.cookie;
    }
  }

  String _getMealTypeName(JournalMealType mealType) {
    switch (mealType) {
      case JournalMealType.breakfast:
        return 'Breakfast';
      case JournalMealType.lunch:
        return 'Lunch';
      case JournalMealType.dinner:
        return 'Dinner';
      case JournalMealType.snack:
        return 'Snack';
    }
  }

  // Navigation methods
  void _navigateToLogMeal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyFoodJournalScreen(),
      ),
    );
  }

  void _navigateToAIDietitian() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AIDietitianChatScreen(),
      ),
    );
  }

  void _navigateToWeeklyPlanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WeeklyMealPlannerScreen(),
      ),
    );
  }

  void _navigateToNutritionDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NutritionDashboardScreen(),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final journalService = Provider.of<JournalService>(context, listen: false);
    await journalService.syncPendingEntries();
  }
}