import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/core/logging/error_reporting.dart';

/// Installs error handlers for the Flutter framework and root isolate.
abstract final class AppErrorHandlers {
  /// Connects both global hooks to the reporting boundary.
  static void install({
    required ErrorReporting reporting,
    required bool presentFlutterErrors,
  }) {
    FlutterError.onError = (details) {
      if (presentFlutterErrors) FlutterError.presentError(details);
      reporting.capture(
        details.exception,
        details.stack ?? StackTrace.current,
        context: 'flutter',
      );
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      reporting.capture(error, stackTrace, context: 'platform');
      return true;
    };
  }
}
