import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/nutrition_service.dart';
import '../../models/nutrition_snapshot.dart';

class NutritionSnapshotCard extends StatefulWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const NutritionSnapshotCard({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<NutritionSnapshotCard> createState() => _NutritionSnapshotCardState();
}

class _NutritionSnapshotCardState extends State<NutritionSnapshotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    return Consumer<NutritionService>(
      builder: (context, nutritionService, _) {
        final snapshot = nutritionService.todaySnapshot;
        
        if (snapshot == null) {
          return _buildLoadingCard();
        }
        
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getScoreColor(snapshot.nutritionScore).withOpacity(0.1),
                  _getScoreColor(snapshot.nutritionScore).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getScoreColor(snapshot.nutritionScore).withOpacity(0.3),
                width: 1,
              ),
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
                _buildHeader(snapshot),
                const SizedBox(height: 20),
                _buildScoreCircle(snapshot),
                if (widget.showDetails) ...[
                  const SizedBox(height: 20),
                  _buildMacroBreakdown(snapshot),
                  const SizedBox(height: 16),
                  _buildInsights(snapshot),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading Nutrition Data...',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calculating your daily snapshot',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NutritionSnapshot snapshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Nutrition',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatDate(snapshot.date),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getScoreColor(snapshot.nutritionScore).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getScoreIcon(snapshot.nutritionScore),
                size: 16,
                color: _getScoreColor(snapshot.nutritionScore),
              ),
              const SizedBox(width: 4),
              Text(
                _getScoreLabel(snapshot.nutritionScore),
                style: AppTextStyles.labelSmall.copyWith(
                  color: _getScoreColor(snapshot.nutritionScore),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildScoreCircle(NutritionSnapshot snapshot) {
    return Row(
      children: [
        // Animated score circle
        AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) {
            return SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  // Background circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                  ),
                  // Progress circle
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _ScoreCirclePainter(
                      progress: _scoreAnimation.value * (snapshot.nutritionScore / 100),
                      color: _getScoreColor(snapshot.nutritionScore),
                    ),
                  ),
                  // Score text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(snapshot.nutritionScore * _scoreAnimation.value).toInt()}',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(snapshot.nutritionScore),
                          ),
                        ),
                        Text(
                          'Score',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(width: 20),
        
        // Quick stats
        Expanded(
          child: Column(
            children: [
              _buildQuickStat(
                'Calories',
                '${snapshot.macros['calories']?.toInt() ?? 0}',
                '${snapshot.goals['calories']?.toInt() ?? 0}',
                snapshot.progress['calories'] ?? 0,
              ),
              const SizedBox(height: 8),
              _buildQuickStat(
                'Protein',
                '${snapshot.macros['protein']?.toInt() ?? 0}g',
                '${snapshot.goals['protein']?.toInt() ?? 0}g',
                snapshot.progress['protein'] ?? 0,
              ),
              const SizedBox(height: 8),
              _buildQuickStat(
                'Water',
                '${snapshot.waterGlasses}',
                '${snapshot.goals['water']?.toInt() ?? 8} glasses',
                snapshot.progress['water'] ?? 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String current, String goal, double progress) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$current / $goal',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(
                value: (progress / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
                minHeight: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBreakdown(NutritionSnapshot snapshot) {
    final macros = snapshot.macros;
    final protein = macros['protein'] ?? 0;
    final carbs = macros['carbs'] ?? 0;
    final fats = macros['fats'] ?? 0;
    final total = protein + carbs + fats;

    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macro Breakdown',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMacroBar(protein / total, Colors.red, 'Protein'),
            const SizedBox(width: 4),
            _buildMacroBar(carbs / total, Colors.orange, 'Carbs'),
            const SizedBox(width: 4),
            _buildMacroBar(fats / total, Colors.green, 'Fats'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMacroLegend('P', '${protein.toInt()}g', Colors.red),
            _buildMacroLegend('C', '${carbs.toInt()}g', Colors.orange),
            _buildMacroLegend('F', '${fats.toInt()}g', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroBar(double ratio, Color color, String label) {
    return Expanded(
      flex: (ratio * 100).toInt(),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildMacroLegend(String letter, String amount, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$letter: $amount',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInsights(NutritionSnapshot snapshot) {
    if (snapshot.insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Insights',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...snapshot.insights.take(2).map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  insight,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // Helper methods
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) return Icons.check_circle;
    if (score >= 60) return Icons.warning;
    return Icons.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    return 'Needs Work';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}