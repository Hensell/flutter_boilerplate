import 'dart:developer';

import 'package:flutter_boilerplate/core/logging/error_reporter.dart';

/// A log destination with injectable diagnostics for tests.
typedef ErrorLogWriter = void Function(
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

/// Default reporter that keeps errors in the local developer console.
class ConsoleErrorReporter implements ErrorReporter {
  /// Creates a reporter using the platform logger unless a writer is supplied.
  const new({this._writer = log});

  final ErrorLogWriter _writer;

  @override
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) async {
    _writer(
      'Application error (${context ?? 'unknown'})',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
