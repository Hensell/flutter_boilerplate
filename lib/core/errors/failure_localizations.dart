import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';

/// Converts domain failure categories into localized presentation messages.
extension FailureLocalizations on AppLocalizations {
  /// Returns a safe message without exposing diagnostic causes.
  String failureMessage(FailureKind failure) => switch (failure) {
    FailureKind.storage => storageError,
    FailureKind.invalidData => invalidDataError,
    FailureKind.invalidNote => invalidNoteError,
    FailureKind.network => networkError,
    FailureKind.timeout => timeoutError,
    FailureKind.server => serverError,
    FailureKind.invalidResponse => invalidResponseError,
    FailureKind.unexpected => unexpectedError,
  };
}
