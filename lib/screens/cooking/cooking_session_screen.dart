import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../services/cooking_session_service.dart';

class CookingSessionScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingSessionScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<CookingSessionScreen> createState() => _CookingSessionScreenState();
}

class _CookingSessionScreenState extends State<CookingSessionScreen> {
  late CookingSessionService _cookingService;

  @override
  void initState() {
    super.initState();
    _cookingService = CookingSessionService();
    
    // Keep screen awake during cooking
    Wakelock.enable();
    
    // Hide status bar for fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Start cooking session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cookingService.startSession(widget.recipe);
    });
  }

  @override
  void dispose() {
    // Restore normal UI and screen behavior
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cookingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _cookingService,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<CookingSessionService>(
            builder: (context, service, _) {
              if (service.isCompleted) {
                return _buildCompletionScreen();
              }
              
              return _buildCookingInterface(service);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCookingInterface(CookingSessionService service) {
    final currentStep = service.currentStep;
    
    if (currentStep == null) {
      return const Center(
        child: Text(
          'No cooking steps available',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(service),
        _buildProgressBar(service),
        Expanded(
          child: _buildStepCard(service, currentStep),
        ),
        _buildControls(service),
      ],
    );
  }

  Widget _buildHeader(CookingSessionService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _showExitDialog,
            icon: const Icon(Icons.close, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          
          Column(
            children: [
              Text(
                widget.recipe.title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Step ${service.currentStepIndex + 1} of ${service.totalSteps}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          IconButton(
            onPressed: service.togglePause,
            icon: Icon(
              service.isPaused ? Icons.play_arrow : Icons.pause,
              size: 28,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(CookingSessionService service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: LinearProgressIndicator(
        value: service.progress,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 6,
      ),
    );
  }

  Widget _buildStepCard(CookingSessionService service, currentStep) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${currentStep.stepNumber}',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Step instruction
          Text(
            currentStep.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Timer display
          if (currentStep.hasTimer) ...[
            _buildTimerDisplay(service),
          ] else ...[
            _buildManualAdvancePrompt(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(CookingSessionService service) {
    final isActive = service.remainingTime.inSeconds > 0;
    
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.grey.shade300,
              width: 3,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  color: isActive ? AppColors.primary : Colors.grey.shade400,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  service.formattedRemainingTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.primary : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (isActive) ...[
          Text(
            service.isPaused ? 'Timer Paused' : 'Timer Running',
            style: AppTextStyles.bodyMedium.copyWith(
              color: service.isPaused ? Colors.orange : AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          Text(
            'Timer Complete',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildManualAdvancePrompt() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.touch_app,
                color: Colors.blue.shade600,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap "Next Step" when ready',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(CookingSessionService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: service.hasPreviousStep ? service.previousStep : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Skip timer button (if timer is active)
          if (service.currentStep?.hasTimer == true && service.remainingTime.inSeconds > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: service.skipTimer,
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip Timer'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Next button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: service.nextStep,
              icon: Icon(service.hasNextStep ? Icons.arrow_forward : Icons.check),
              label: Text(service.hasNextStep ? 'Next Step' : 'Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Cooking Complete!',
              style: AppTextStyles.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Great job! You\'ve successfully completed cooking ${widget.recipe.title}. Enjoy your delicious meal!',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text('Back to Recipe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Cooking Mode?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit cooking screen
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}