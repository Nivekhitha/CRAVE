import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/cooking_step.dart';
import '../models/recipe.dart';

/// Service to manage hands-free cooking sessions with voice guidance and timers
class CookingSessionService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  
  List<CookingStep> _steps = [];
  int _currentStepIndex = 0;
  Timer? _stepTimer;
  Duration _remainingTime = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;

  // Getters
  List<CookingStep> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  CookingStep? get currentStep => _currentStepIndex < _steps.length ? _steps[_currentStepIndex] : null;
  Duration get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isCompleted => _isCompleted;
  bool get hasNextStep => _currentStepIndex < _steps.length - 1;
  bool get hasPreviousStep => _currentStepIndex > 0;
  int get totalSteps => _steps.length;
  double get progress => _steps.isEmpty ? 0.0 : (_currentStepIndex + 1) / _steps.length;

  /// Initialize cooking session with recipe
  Future<void> startSession(Recipe recipe) async {
    await _initializeTTS();
    
    _steps = CookingStep.parseSteps(recipe.instructions ?? '');
    _currentStepIndex = 0;
    _isRunning = true;
    _isPaused = false;
    _isCompleted = false;
    
    debugPrint('🍳 Starting cooking session with ${_steps.length} steps');
    
    if (_steps.isNotEmpty) {
      await _startCurrentStep();
    }
    
    notifyListeners();
  }

  /// Initialize Text-to-Speech
  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5); // Slightly slower for cooking
      await _tts.setVolume(0.8);
      await _tts.setPitch(1.0);
      
      debugPrint('✅ TTS initialized');
    } catch (e) {
      debugPrint('❌ TTS initialization failed: $e');
    }
  }

  /// Start the current step (speak + timer if needed)
  Future<void> _startCurrentStep() async {
    final step = currentStep;
    if (step == null) return;

    debugPrint('🎯 Starting step ${step.stepNumber}: ${step.text}');
    
    // Speak the step
    await _speak(step.text);
    
    // Start timer if step has duration
    if (step.hasTimer) {
      _startTimer(step.duration!);
    }
    
    notifyListeners();
  }

  /// Speak text using TTS
  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS speak failed: $e');
    }
  }

  /// Start countdown timer for current step
  void _startTimer(Duration duration) {
    _stopTimer(); // Stop any existing timer
    
    _remainingTime = duration;
    debugPrint('⏰ Starting timer for ${duration.inMinutes} minutes');
    
    _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      
      _remainingTime = _remainingTime - const Duration(seconds: 1);
      
      if (_remainingTime.inSeconds <= 0) {
        _onTimerComplete();
      }
      
      notifyListeners();
    });
  }

  /// Handle timer completion
  Future<void> _onTimerComplete() async {
    _stopTimer();
    
    debugPrint('⏰ Timer completed for step ${currentStep?.stepNumber}');
    
    // Announce timer completion
    if (hasNextStep) {
      final nextStep = _steps[_currentStepIndex + 1];
      await _speak("Time's up! Next step: ${nextStep.text}");
      
      // Auto-advance to next step after a brief pause
      await Future.delayed(const Duration(seconds: 2));
      await nextStep();
    } else {
      await _speak("Time's up! You're almost done!");
    }
  }

  /// Move to next step
  Future<void> nextStep() async {
    if (!hasNextStep) {
      await _completeSession();
      return;
    }
    
    _stopTimer();
    _currentStepIndex++;
    
    debugPrint('➡️ Moving to step ${_currentStepIndex + 1}');
    
    if (_currentStepIndex >= _steps.length) {
      await _completeSession();
    } else {
      await _startCurrentStep();
    }
  }

  /// Move to previous step
  Future<void> previousStep() async {
    if (!hasPreviousStep) return;
    
    _stopTimer();
    _currentStepIndex--;
    
    debugPrint('⬅️ Moving to step ${_currentStepIndex + 1}');
    await _startCurrentStep();
  }

  /// Pause/Resume session
  void togglePause() {
    _isPaused = !_isPaused;
    debugPrint('⏸️ Session ${_isPaused ? 'paused' : 'resumed'}');
    notifyListeners();
  }

  /// Skip current timer (if running)
  Future<void> skipTimer() async {
    if (_stepTimer?.isActive == true) {
      _stopTimer();
      await _speak("Timer skipped. Moving on.");
      await Future.delayed(const Duration(seconds: 1));
      await nextStep();
    }
  }

  /// Complete the cooking session
  Future<void> _completeSession() async {
    _stopTimer();
    _isRunning = false;
    _isCompleted = true;
    
    debugPrint('🎉 Cooking session completed!');
    
    await _speak("Excellent work! You've finished cooking. Enjoy your meal!");
    
    notifyListeners();
  }

  /// Stop current timer
  void _stopTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
    _remainingTime = Duration.zero;
  }

  /// End session early
  Future<void> endSession() async {
    _stopTimer();
    _isRunning = false;
    _isCompleted = false;
    
    await _tts.stop();
    
    debugPrint('🛑 Cooking session ended');
    notifyListeners();
  }

  /// Format remaining time for display
  String get formattedRemainingTime {
    if (_remainingTime.inSeconds <= 0) return '0:00';
    
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    _tts.stop();
    super.dispose();
  }
}