/// Lightweight runtime model for cooking steps
class CookingStep {
  final String text;
  final Duration? duration;
  final int stepNumber;

  const CookingStep({
    required this.text,
    this.duration,
    required this.stepNumber,
  });

  /// Parse cooking instructions into structured steps with durations
  static List<CookingStep> parseSteps(String instructions) {
    if (instructions.isEmpty) return [];

    final steps = instructions.split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final stepText = entry.value.trim();
      final duration = _extractDuration(stepText);

      return CookingStep(
        text: stepText,
        duration: duration,
        stepNumber: index + 1,
      );
    }).toList();
  }

  /// Extract duration from step text using regex
  static Duration? _extractDuration(String text) {
    // Pattern matches: "2 min", "5 mins", "10 minutes", "15 minute"
    final regex = RegExp(r'(\d+)\s*(min|mins|minute|minutes)\b', caseSensitive: false);
    final match = regex.firstMatch(text);
    
    if (match != null) {
      final minutes = int.tryParse(match.group(1) ?? '');
      if (minutes != null && minutes > 0) {
        return Duration(minutes: minutes);
      }
    }
    
    return null;
  }

  /// Get friendly duration text for display
  String get durationText {
    if (duration == null) return '';
    
    final minutes = duration!.inMinutes;
    if (minutes == 1) return '1 minute';
    return '$minutes minutes';
  }

  /// Check if this step has a timer
  bool get hasTimer => duration != null;

  @override
  String toString() => 'CookingStep(#$stepNumber: $text${hasTimer ? ' [$durationText]' : ''})';
}