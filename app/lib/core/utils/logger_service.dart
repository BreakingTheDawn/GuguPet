import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _instance;

  static Logger get instance {
    _instance ??= Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
      level: kDebugMode ? Level.trace : Level.off,
    );
    return _instance!;
  }

  static void debug(String message) {
    instance.d(message);
  }

  static void info(String message) {
    instance.i(message);
  }

  static void warning(String message) {
    instance.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void trace(String message) {
    instance.t(message);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }
}
