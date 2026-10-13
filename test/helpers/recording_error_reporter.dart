import 'package:flutter_boilerplate/core/logging/error_reporter.dart';

class RecordingErrorReporter implements ErrorReporter {
  final records = <(Object, StackTrace, String?)>[];

  @override
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) async {
    records.add((error, stackTrace, context));
  }
}
