import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<int>> _durations = {};

  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  static void endTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime == null) {
      debugPrint('⚠️ No start time found for operation: $operation');
      return;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    // Store duration for analysis
    _durations[operation] ??= [];
    _durations[operation]!.add(duration);

    // Log performance
    debugPrint('⏱️ $operation took ${duration}ms');

    // Warn about slow operations
    if (duration > 1000) {
      debugPrint('🐌 SLOW OPERATION: $operation took ${duration}ms');
    }

    _startTimes.remove(operation);
  }

  static void logStats() {
    debugPrint('📊 Performance Statistics:');
    _durations.forEach((operation, durations) {
      final avg = durations.reduce((a, b) => a + b) / durations.length;
      final max = durations.reduce((a, b) => a > b ? a : b);
      final min = durations.reduce((a, b) => a < b ? a : b);

      debugPrint(
          '  $operation: avg=${avg.toStringAsFixed(1)}ms, max=${max}ms, min=${min}ms, count=${durations.length}');
    });
  }

  static void reset() {
    _startTimes.clear();
    _durations.clear();
  }

  // Wrapper for timing async operations
  static Future<T> timeAsync<T>(
      String operation, Future<T> Function() function) async {
    startTimer(operation);
    try {
      final result = await function();
      endTimer(operation);
      return result;
    } catch (e) {
      endTimer(operation);
      rethrow;
    }
  }

  // Wrapper for timing sync operations
  static T timeSync<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      endTimer(operation);
      return result;
    } catch (e) {
      endTimer(operation);
      rethrow;
    }
  }
}
