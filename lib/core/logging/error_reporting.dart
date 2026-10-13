import 'dart:async';
import 'dart:developer';

import 'package:flutter_boilerplate/core/logging/console_error_reporter.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';

/// Keeps reporting failures from replacing or recursively reporting app errors.
class ErrorReporting {
  /// Creates the fail-safe reporting boundary.
  const new({required this._reporter, this._fallbackWriter = log});

  final ErrorReporter _reporter;
  final ErrorLogWriter _fallbackWriter;

  /// Starts reporting without introducing an unhandled asynchronous failure.
  void capture(Object error, StackTrace stackTrace, {String? context}) {
    unawaited(_report(error, stackTrace, context: context));
  }

  Future<void> _report(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) async {
    try {
      await _reporter.report(error, stackTrace, context: context);
    } on Object catch (reporterError, reporterStack) {
      // A broken reporter must not recurse into global error handlers.
      _fallbackWriter(
        'Error reporter failed',
        error: reporterError,
        stackTrace: reporterStack,
      );
    }
  }
}
