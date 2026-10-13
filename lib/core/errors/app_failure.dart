/// Failures understood by the domain and presentation layers.
enum FailureKind {
  /// Local data could not be read or saved.
  storage,

  /// Persisted data does not match the expected format.
  invalidData,

  /// The submitted note is empty or exceeds its length limit.
  invalidNote,

  /// The remote server could not be reached.
  network,

  /// The full response was not received before its deadline.
  timeout,

  /// The remote server returned an unsuccessful HTTP status.
  server,

  /// The remote response does not match the expected contract.
  invalidResponse,

  /// An unexpected implementation failure interrupted an operation.
  unexpected,
}

/// A typed failure that avoids exposing infrastructure errors to the UI.
class AppFailure implements Exception {
  /// Creates a failure with an optional diagnostic cause.
  const new(this.kind, {this.cause});

  /// The category used to select a localized message.
  final FailureKind kind;

  /// The original error, intended only for diagnostics.
  final Object? cause;
}

/// Classification used only for handled BLoC/Cubit failures.
extension AppFailureClassification on AppFailure {
  /// Whether this is an expected, user-recoverable operation failure.
  bool get isExpected => switch (kind) {
    FailureKind.storage ||
    FailureKind.invalidNote ||
    FailureKind.network ||
    FailureKind.timeout ||
    FailureKind.server => true,
    FailureKind.invalidData ||
    FailureKind.invalidResponse ||
    FailureKind.unexpected => false,
  };
}
