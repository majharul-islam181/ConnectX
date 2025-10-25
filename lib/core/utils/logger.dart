import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../config/app_flavor.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class AppLogger {
  static const String _tag = 'ConnectX';
  AppLogger._();

  /// Check if logging is enabled based on flavor
  static bool get _isLoggingEnabled {
    try {
      return AppFlavor.instance.values.enableLogging;
    } catch (e) {
      return kDebugMode;
    }
  }

  /// Debug level logging
  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    _log(
      level: LogLevel.debug,
      message: message,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );
  }

  /// Info level logging
  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    _log(
      level: LogLevel.info,
      message: message,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );
  }

  /// Warning level logging
  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    _log(
      level: LogLevel.warning,
      message: message,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );
  }

  /// Error level logging
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    _log(
      level: LogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );
  }

  /// Fatal level logging
  static void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    _log(
      level: LogLevel.fatal,
      message: message,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );
  }

  /// API request logging
  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
  }) {
    if (!_isLoggingEnabled) return;

    final buffer = StringBuffer();
    buffer.writeln('🚀 API REQUEST [$method]');
    buffer.writeln('URL: $url');

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('Headers: $headers');
    }

    if (data != null) {
      buffer.writeln('Data: $data');
    }

    _log(level: LogLevel.info, message: buffer.toString());
  }

  /// API response logging
  static void apiResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic data,
    Duration? duration,
  }) {
    if (!_isLoggingEnabled) return;

    final buffer = StringBuffer();
    buffer.writeln('✅ API RESPONSE [$method] [$statusCode]');
    buffer.writeln('URL: $url');

    if (duration != null) {
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    }

    if (data != null) {
      buffer.writeln('Data: $data');
    }

    _log(level: LogLevel.info, message: buffer.toString());
  }

  /// API error logging
  static void apiError({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
    int? statusCode,
  }) {
    if (!_isLoggingEnabled) return;

    final buffer = StringBuffer();
    buffer.writeln(
        '❌ API ERROR [$method]${statusCode != null ? ' [$statusCode]' : ''}');
    buffer.writeln('URL: $url');
    buffer.writeln('Error: $error');

    _log(
      level: LogLevel.error,
      message: buffer.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Bloc state logging
  static void blocTransition({
    required String blocName,
    required String currentState,
    required String event,
    required String nextState,
  }) {
    if (!_isLoggingEnabled) return;

    final message = '🔄 BLOC TRANSITION [$blocName]\n'
        'Event: $event\n'
        'Current: $currentState\n'
        'Next: $nextState';

    _log(level: LogLevel.debug, message: message);
  }

  /// Navigation logging
  static void navigation({
    required String from,
    required String to,
    Object? arguments,
  }) {
    if (!_isLoggingEnabled) return;

    final buffer = StringBuffer();
    buffer.writeln('🧭 NAVIGATION');
    buffer.writeln('From: $from');
    buffer.writeln('To: $to');

    if (arguments != null) {
      buffer.writeln('Arguments: $arguments');
    }

    _log(level: LogLevel.debug, message: buffer.toString());
  }

  /// Performance logging
  static void performance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isLoggingEnabled) return;

    final buffer = StringBuffer();
    buffer.writeln('⚡ PERFORMANCE');
    buffer.writeln('Operation: $operation');
    buffer.writeln('Duration: ${duration.inMilliseconds}ms');

    if (metadata != null) {
      buffer.writeln('Metadata: $metadata');
    }

    _log(level: LogLevel.info, message: buffer.toString());
  }

  /// Cache operation logging
  static void cache({
    required String operation,
    required String key,
    bool? hit,
    String? size,
  }) {
    if (!_isLoggingEnabled) return;

    final buffer = StringBuffer();
    buffer.writeln('💾 CACHE ${operation.toUpperCase()}');
    buffer.writeln('Key: $key');

    if (hit != null) {
      buffer.writeln('Hit: ${hit ? 'YES' : 'NO'}');
    }

    if (size != null) {
      buffer.writeln('Size: $size');
    }

    _log(level: LogLevel.debug, message: buffer.toString());
  }

  /// Core logging method
  static void _log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!_isLoggingEnabled) return;

    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final flavorStr = AppFlavor.instance.environmentShort;

    final formattedMessage = '[$timestamp] [$flavorStr] [$levelStr] $message';

    developer.log(
      formattedMessage,
      name: logTag,
      error: error,
      stackTrace: stackTrace,
      level: _getLogLevelInt(level),
    );
    if (kDebugMode) {
      print('$logTag: $formattedMessage');

      if (error != null) {
        print('$logTag: Error: $error');
      }

      if (stackTrace != null) {
        print('$logTag: StackTrace: $stackTrace');
      }
    }
  }

  /// Convert LogLevel to int for developer.log
  static int _getLogLevelInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }
}
