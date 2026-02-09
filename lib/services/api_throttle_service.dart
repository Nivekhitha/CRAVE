import 'dart:async';
import 'package:flutter/foundation.dart';

class ApiThrottleService {
  static final Map<String, DateTime> _lastCalls = {};
  static const Duration _minInterval = Duration(seconds: 2); // 2s between calls

  /// Throttles calls to the given API key.
  /// If called too frequently, it waits until the interval has passed.
  static Future<void> throttle(String apiKey) async {
    final now = DateTime.now();
    final lastCall = _lastCalls[apiKey];

    if (lastCall != null) {
      final timeSince = now.difference(lastCall);
      if (timeSince < _minInterval) {
        final waitTime = _minInterval - timeSince;
        debugPrint("⏳ Throttling API ($apiKey) for ${waitTime.inMilliseconds}ms");
        await Future.delayed(waitTime);
      }
    }

    _lastCalls[apiKey] = DateTime.now();
  }
}
