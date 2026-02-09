
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../services/cooking_session_service.dart';
import '../../providers/user_provider.dart';
import 'dart:async';

class CookingScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingScreen({super.key, required this.recipe});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  // PageController for manual swiping if desired, though buttons are primary
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Enable screen wakelock
    WakelockPlus.enable();
    
    // Start session
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<CookingSessionService>().startSession(widget.recipe);
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CookingSessionService>(
      builder: (context, session, child) {
        if (session.isCompleted) {
          return _buildCompletionScreen(context);
        }

        final step = session.currentStep;
        
        // Sync PageController if needed (optional)
        if (_pageController.hasClients && _pageController.page?.round() != session.currentStepIndex) {
            _pageController.animateToPage(
              session.currentStepIndex, 
              duration: const Duration(milliseconds: 300), 
              curve: Curves.easeInOut
            );
        }

        return PopScope(
          canPop: false, // Prevent default pop
          onPopInvoked: (didPop) async {
            if (didPop) return;
            await _confirmExit(context);
          },
          child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
              onPressed: () => _confirmExit(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  session.isPaused ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.primary,
                  size: 28,
                ),
                onPressed: () => session.togglePause(), // Or distinct logic for voice mute
              )
            ],
          ),
          body: Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: session.progress,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
              
              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe to force button usage/logic sync
                  itemCount: session.totalSteps,
                  itemBuilder: (context, index) {
                     // We only show the current step from session to ensure sync
                     // But PageView is used for layout structure if we wanted animations.
                     // Simpler: Just show current step content directly.
                     return _buildStepContent(context, session);
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomControls(context, session),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, CookingSessionService session) {
    final step = session.currentStep;
    if (step == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'STEP ${step.stepNumber} OF ${session.totalSteps}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            step.text,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              height: 1.4,
              fontSize: 28, // Large text for readability
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 48),
          
          if (step.hasTimer)
            _buildTimer(context, session),
        ],
      ),
    );
  }

  Widget _buildTimer(BuildContext context, CookingSessionService session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        children: [
           Text(
             session.formattedRemainingTime,
             style: AppTextStyles.headlineLarge.copyWith(
               color: AppColors.primary,
               fontWeight: FontWeight.bold,
               fontFeatures: [const FontFeature.tabularFigures()],
             ),
           ),
           const SizedBox(height: 8),
           Text(
             session.isPaused ? 'PAUSED' : 'COOKING...',
             style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
           ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, CookingSessionService session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, -4),
           )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton.filledTonal(
            onPressed: session.hasPreviousStep ? session.previousStep : null,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              minimumSize: const Size(56, 56),
              backgroundColor: AppColors.background,
            ),
          ),
          
          // Action Button (Play/Next/Skip Timer)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Smart Button Logic
                    if (session.remainingTime.inSeconds > 0 && !session.isPaused) {
                       session.skipTimer();
                    } else {
                       session.nextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text(
                    (session.remainingTime.inSeconds > 0) ? 'SKIP TIMER' : 'NEXT STEP',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          
          // Repeat/Pause Button
           IconButton.filledTonal(
            onPressed: session.togglePause,
            icon: Icon(session.isPaused ? Icons.play_arrow : Icons.pause),
             style: IconButton.styleFrom(
              minimumSize: const Size(56, 56),
              backgroundColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'Bon Appétit!',
                style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'You cooked ${widget.recipe.title} like a pro!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<UserProvider>().completeCooking();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('COMPLETE & SAVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Cooking?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Cooking')),
          TextButton(
            onPressed: () {
              context.read<CookingSessionService>().endSession();
              Navigator.pop(context, true);
            }, 
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }
}
