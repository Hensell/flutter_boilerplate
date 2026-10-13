/// Contract for reporting unexpected application errors.
abstract interface class ErrorReporter {
  /// Reports the original error and stack without changing application state.
  Future<void> report(Object error, StackTrace stackTrace, {String? context});
}
