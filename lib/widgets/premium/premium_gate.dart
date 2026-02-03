import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/premium_service.dart';
import 'paywall_view.dart';
import '../../app/app_colors.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureId;
  final Widget? lockedBuilder;

  const PremiumGate({
    super.key,
    required this.child,
    this.featureId = 'generic_feature',
    this.lockedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumService>(
      builder: (context, premiumService, _) {
        if (premiumService.isPremium) {
          return child;
        }

        // Optional: Custom locked view
        if (lockedBuilder != null) {
          return lockedBuilder!;
        }

        // specific check if needed, mostly redundant if gate is used
        if (!premiumService.canUseFeature(featureId)) {
             return _buildLockedOverlay(context, premiumService);
        }
        
        return child;
      },
    );
  }

  Widget _buildLockedOverlay(BuildContext context, PremiumService premiumService) {
      return Stack(
          children: [
              // Blur or disable child
              AbsorbPointer(
                  child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Colors.grey, 
                          BlendMode.saturation
                      ),
                      child: Opacity(opacity: 0.3, child: child),
                  ),
              ),
              
              // Paywall Preview
              Center(
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                              )
                          ]
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.warmPeach),
                              const SizedBox(height: 16),
                              const Text(
                                  "Premium Feature",
                                  style: TextStyle(
                                      fontSize: 20, 
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary
                                  ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                  "Unlock unlimited access to all features.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                  onPressed: () {
                                      // Show full paywall
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => PaywallView(
                                              onUnlock: () async {
                                                  try {
                                                      await premiumService.unlockPremium();
                                                      Navigator.pop(context);
                                                  } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text(e.toString()))
                                                      );
                                                  }
                                              },
                                              isLoading: premiumService.isLoading,
                                          )
                                      );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.freshMint,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
                                  ),
                                  child: const Text("Unlock Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                          ],
                      ),
                  ),
              )
          ],
      );
  }
}
