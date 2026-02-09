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
    // Check for hours first
    final hourRegex = RegExp(r'(\d+)\s*(hour|hr|hours|hrs)\b', caseSensitive: false);
    final hourMatch = hourRegex.firstMatch(text);
    if (hourMatch != null) {
      final hours = int.tryParse(hourMatch.group(1) ?? '');
      if (hours != null && hours > 0) return Duration(hours: hours);
    }

    // Check for minutes (handle ranges like "20-30 mins" by taking lower bound)
    final minRegex = RegExp(r'(\d+)(?:-\d+)?\s*(min|mins|minute|minutes)\b', caseSensitive: false);
    final minMatch = minRegex.firstMatch(text);
    
    if (minMatch != null) {
      final minutes = int.tryParse(minMatch.group(1) ?? '');
      if (minutes != null && minutes > 0) return Duration(minutes: minutes);
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