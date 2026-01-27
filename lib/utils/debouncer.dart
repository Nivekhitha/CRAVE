import 'dart:async';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class ActionThrottler {
  final Map<String, DateTime> _lastActionTimes = {};
  final int cooldownMs;

  ActionThrottler({this.cooldownMs = 1000});

  bool canPerformAction(String actionKey) {
    final now = DateTime.now();
    final lastTime = _lastActionTimes[actionKey];

    if (lastTime == null) {
      _lastActionTimes[actionKey] = now;
      return true;
    }

    final timeDiff = now.difference(lastTime).inMilliseconds;
    if (timeDiff >= cooldownMs) {
      _lastActionTimes[actionKey] = now;
      return true;
    }

    return false;
  }

  void reset(String actionKey) {
    _lastActionTimes.remove(actionKey);
  }

  void resetAll() {
    _lastActionTimes.clear();
  }
}
