import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every failure has a non-empty localized message in both languages',
    () async {
      for (final code in ['es', 'en']) {
        final l10n = await AppLocalizations.delegate.load(Locale(code));
        final messages = FailureKind.values.map(l10n.failureMessage).toList();
        expect(messages.every((message) => message.trim().isNotEmpty), isTrue);
        expect(messages.toSet().length, FailureKind.values.length);
        expect(
          l10n.failureMessage(FailureKind.timeout),
          code == 'es'
              ? 'La respuesta tardó demasiado. Inténtalo de nuevo.'
              : 'The response took too long. Please try again.',
        );
      }
    },
  );
}
