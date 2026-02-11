import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

/// Progressive UI widget for extraction operations
class ExtractionProgressWidget extends StatefulWidget {
  final String currentStep;
  final double? progress; // 0.0 to 1.0, null for indeterminate
  final List<String> completedSteps;
  final List<String> warnings;
  final int? recipesFound;
  final bool isComplete;
  final VoidCallback? onCancel;

  const ExtractionProgressWidget({
    super.key,
    required this.currentStep,
    this.progress,
    this.completedSteps = const [],
    this.warnings = const [],
    this.recipesFound,
    this.isComplete = false,
    this.onCancel,
  });

  @override
  State<ExtractionProgressWidget> createState() => _ExtractionProgressWidgetState();
}

class _ExtractionProgressWidgetState extends State<ExtractionProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                if (!widget.isComplete) ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isComplete ? 'Extraction Complete!' : 'Extracting Recipes',
                        style: AppTextStyles.titleMedium,
                      ),
                      if (widget.recipesFound != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${widget.recipesFound} recipe${widget.recipesFound == 1 ? '' : 's'} found',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.onCancel != null && !widget.isComplete)
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Progress indicator
            if (!widget.isComplete) ...[
              if (widget.progress != null) ...[
                // Determinate progress
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(widget.progress! * 100).toInt()}% complete',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Indeterminate progress
                const LinearProgressIndicator(
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ],
              
              const SizedBox(height: 16),
            ],
            
            // Current step
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isComplete 
                    ? Colors.green.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isComplete 
                      ? Colors.green.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  if (!widget.isComplete) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.currentStep,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.isComplete ? Colors.green : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Completed steps
            if (widget.completedSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...widget.completedSteps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            // Warnings
            if (widget.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Warnings',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $warning',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple extraction status widget for minimal UI
class ExtractionStatusWidget extends StatelessWidget {
  final String message;
  final bool isLoading;
  final Color? color;

  const ExtractionStatusWidget({
    super.key,
    required this.message,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}