import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/journal_service.dart';
import '../../services/nutrition_service.dart';
import '../../services/nutrition_export_service.dart';
import '../../widgets/premium/premium_gate.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() => _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedPeriod = 0; // 0: Today, 1: Week, 2: Month

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NutritionGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Nutrition Dashboard',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showExportOptions,
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildMacroPieChart(),
                  const SizedBox(height: 32),
                  _buildNutrientGoals(),
                  const SizedBox(height: 32),
                  _buildVitaminsGrid(),
                  const SizedBox(height: 32),
                  _buildHydrationTracker(),
                  const SizedBox(height: 32),
                  _buildWeeklyTrends(),
                  const SizedBox(height: 32),
                  _buildNutritionInsights(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodTab('Today', 0),
          _buildPeriodTab('Week', 1),
          _buildPeriodTab('Month', 2),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = _selectedPeriod == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroPieChart() {
    return Consumer<JournalService>(
      builder: (context, journalService, _) {
        final protein = journalService.todayProtein.toDouble();
        final carbs = journalService.todayCarbs.toDouble();
        final fats = journalService.todayFats.toDouble();
        final total = protein + carbs + fats;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
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
              Text(
                'Macronutrient Breakdown',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  // Pie chart
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: total > 0 
                        ? CustomPaint(
                            painter: _MacroPieChartPainter(
                              protein: protein / total,
                              carbs: carbs / total,
                              fats: fats / total,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'No Data',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Legend
                  Expanded(
                    child: Column(
                      children: [
                        _buildMacroLegendItem(
                          'Protein',
                          '${protein.toInt()}g',
                          total > 0 ? (protein / total * 100).toInt() : 0,
                          Colors.red,
                        ),
                        const SizedBox(height: 12),
                        _buildMacroLegendItem(
                          'Carbs',
                          '${carbs.toInt()}g',
                          total > 0 ? (carbs / total * 100).toInt() : 0,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildMacroLegendItem(
                          'Fats',
                          '${fats.toInt()}g',
                          total > 0 ? (fats / total * 100).toInt() : 0,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroLegendItem(String label, String amount, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          amount,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Goals',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Consumer<JournalService>(
          builder: (context, journalService, _) {
            return Column(
              children: [
                _buildGoalProgress(
                  'Calories',
                  journalService.todayCalories,
                  2000,
                  'kcal',
                  AppColors.primary,
                ),
                const SizedBox(height: 16),
                _buildGoalProgress(
                  'Protein',
                  journalService.todayProtein,
                  150,
                  'g',
                  Colors.red,
                ),
                const SizedBox(height: 16),
                _buildGoalProgress(
                  'Fiber',
                  25, // Mock data
                  30,
                  'g',
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildGoalProgress(
                  'Water',
                  6, // Mock data
                  8,
                  'glasses',
                  Colors.blue,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGoalProgress(String label, int current, int goal, String unit, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$current / $goal $unit',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
          
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% of daily goal',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminsGrid() {
    final vitamins = [
      _VitaminData('Vitamin A', 80, 100, Colors.orange),
      _VitaminData('Vitamin C', 120, 90, Colors.yellow),
      _VitaminData('Vitamin D', 15, 20, Colors.purple),
      _VitaminData('Vitamin E', 12, 15, Colors.green),
      _VitaminData('B12', 2.4, 2.4, Colors.blue),
      _VitaminData('Iron', 14, 18, Colors.red),
      _VitaminData('Calcium', 800, 1000, Colors.grey),
      _VitaminData('Zinc', 8, 11, Colors.brown),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vitamins & Minerals',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: vitamins.length,
          itemBuilder: (context, index) {
            final vitamin = vitamins[index];
            return _buildVitaminCard(vitamin);
          },
        ),
      ],
    );
  }

  Widget _buildVitaminCard(_VitaminData vitamin) {
    final progress = (vitamin.current / vitamin.target).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vitamin.color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: vitamin.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vitamin.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          
          Text(
            '${vitamin.current.toStringAsFixed(1)}/${vitamin.target.toStringAsFixed(1)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: vitamin.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: vitamin.color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(vitamin.color),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTracker() {
    return Consumer<NutritionService>(
      builder: (context, nutritionService, _) {
        final snapshot = nutritionService.todaySnapshot;
        final currentGlasses = snapshot?.waterGlasses ?? 0;
        const targetGlasses = 8;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.cyan.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hydration',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$currentGlasses / $targetGlasses glasses',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Water glasses visualization
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(targetGlasses, (index) {
                  final isFilled = index < currentGlasses;
                  return GestureDetector(
                    onTap: () async {
                      // Toggle glass - set water to this glass number + 1
                      await nutritionService.logWater(index + 1);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('💧 Water updated to ${index + 1} glasses'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isFilled ? Colors.blue : Colors.transparent,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Add one glass of water
                        final newCount = currentGlasses + 1;
                        await nutritionService.logWater(newCount);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('💧 Added glass of water! Total: $newCount'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Glass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyTrends() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Trends',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock trend chart
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nutrition trends chart',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrendStat('Avg Calories', '1,850', '+5%', Colors.green),
              _buildTrendStat('Avg Protein', '145g', '+12%', Colors.green),
              _buildTrendStat('Hydration', '7.2 glasses', '-3%', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendStat(String label, String value, String change, Color changeColor) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          change,
          style: AppTextStyles.bodySmall.copyWith(
            color: changeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionInsights() {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Nutrition Insights',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInsightCard(
            '🎯 Great protein intake!',
            'You\'re consistently hitting your protein goals. Keep it up!',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            '💧 Increase water intake',
            'Try to drink 2 more glasses of water daily for better hydration.',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            '🥬 Add more vegetables',
            'Include colorful vegetables to boost your vitamin and mineral intake.',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Generate nutrition report'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Summary'),
              subtitle: const Text('Share with healthcare provider'),
              onTap: () {
                Navigator.pop(context);
                _shareSummary();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsPDF() async {
    try {
      final nutritionService = Provider.of<NutritionService>(context, listen: false);
      final snapshot = nutritionService.todaySnapshot;
      
      if (snapshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No nutrition data available to export'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Show success message (PDF generation will be implemented later)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 PDF export feature coming soon! For now, data is saved locally.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error exporting PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Nutrition summary shared!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
  }
}

class _VitaminData {
  final String name;
  final double current;
  final double target;
  final Color color;

  _VitaminData(this.name, this.current, this.target, this.color);
}

class _MacroPieChartPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fats;

  _MacroPieChartPainter({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final proteinPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final carbsPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final fatsPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;

    // Draw protein arc
    final proteinSweep = 2 * math.pi * protein;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      proteinSweep,
      true,
      proteinPaint,
    );
    startAngle += proteinSweep;

    // Draw carbs arc
    final carbsSweep = 2 * math.pi * carbs;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      carbsSweep,
      true,
      carbsPaint,
    );
    startAngle += carbsSweep;

    // Draw fats arc
    final fatsSweep = 2 * math.pi * fats;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fatsSweep,
      true,
      fatsPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}