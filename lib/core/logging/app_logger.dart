import 'dart:developer' as developer;

import 'package:logging/logging.dart';

/// Centralized structured logging setup built on `package:logging`.
abstract final class AppLogger {
  static bool _initialized = false;

  static void initialize({required bool enableDebugLogging}) {
    if (_initialized) {
      return;
    }
    _initialized = true;

    hierarchicalLoggingEnabled = true;
    Logger.root.level = enableDebugLogging ? Level.ALL : Level.WARNING;
    Logger.root.onRecord.listen((record) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });
  }

  static Logger named(String name) => Logger('ritma.$name');
}
