import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/l10n/gen/app_localizations.dart';

export 'package:flutter_boilerplate/l10n/gen/app_localizations.dart';

/// Provides localized strings from the current context.
extension AppLocalizationsX on BuildContext {
  /// The localizations for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
