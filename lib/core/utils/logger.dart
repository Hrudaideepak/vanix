import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      print('👾 [VANIX DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) print('ℹ️ [VANIX INFO] $message');
  }

  static void warning(String message) {
    if (kDebugMode) print('⚠️ [VANIX WARNING] $message');
  }

  static void error(String message) {
    if (kDebugMode) print('🔴 [VANIX ERROR] $message');
  }
}
