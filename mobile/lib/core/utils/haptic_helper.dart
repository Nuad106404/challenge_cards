import 'package:flutter/services.dart';

class HapticHelper {
  HapticHelper._();

  static DateTime? _lastHapticTime;
  static const _debounceDuration = Duration(milliseconds: 250);

  static bool _canTrigger() {
    final now = DateTime.now();
    if (_lastHapticTime == null ||
        now.difference(_lastHapticTime!) > _debounceDuration) {
      _lastHapticTime = now;
      return true;
    }
    return false;
  }

  static Future<void> light() async {
    if (_canTrigger()) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (_canTrigger()) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    if (_canTrigger()) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> selection() async {
    if (_canTrigger()) {
      await HapticFeedback.selectionClick();
    }
  }
}
