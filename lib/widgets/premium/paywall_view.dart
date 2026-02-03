import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class PaywallView extends StatelessWidget {
  final VoidCallback onUnlock;
  final bool isLoading;

  const PaywallView({
    super.key,
    required this.onUnlock,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Image / Gradient
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9A9E), Color(0xFFFF7D54)], // Peach Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                 BoxShadow(
                    color: const Color(0xFFFF7D54).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                 )
              ]
            ),
            child: Stack(
              children: [
                Positioned.fill(
                   child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CustomPaint(
                         painter: CirclePatternPainter(),
                      ),
                   ) 
                ),
                Center(
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                          const SizedBox(height: 8),
                          Text(
                             "CRAVE PREMIUM",
                             style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.2
                             ),
                          )
                       ],
                    )
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Title
          Text(
            'Unlock Your\nPersonal AI Dietitian',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
               fontSize: 28,
               height: 1.1,
               color: AppColors.textPrimary
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
             "Track meals, plan your week, and get\npersonalized nutrition guidance.",
             textAlign: TextAlign.center,
             style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          // Benefits
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
               children: [
                  _buildBenefitRow('Worry-free journal'),
                  const SizedBox(height: 16),
                  _buildBenefitRow('Weekly meal planning'),
                  const SizedBox(height: 16),
                  _buildBenefitRow('Nutrition dashboard 24/7'),
                  const SizedBox(height: 16),
                  _buildBenefitRow('Personal AI Dietitian'),
               ],
            ),
          ),

          const SizedBox(height: 40),

          // Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onUnlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7D54), // Direct match to gradient
                  elevation: 0,
                  shadowColor: const Color(0xFFFF7D54).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Start Premium',
                        style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      children: [
        Container(
           padding: const EdgeInsets.all(4),
           decoration: const BoxDecoration(
              color: Color(0xFFFF7D54),
              shape: BoxShape.circle
           ),
           child: const Icon(Icons.check, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Text(
           text, 
           style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary
           )
        ),
      ],
    );
  }
}

class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 40, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
