import 'package:equatable/equatable.dart';

/// Languages supported by the app.
enum AppLanguage {
  /// Spanish interface.
  spanish('es'),

  /// English interface.
  english('en');

  new(this.code);

  /// The language code passed to the presentation layer.
  final String code;
}

/// Monochrome appearance options.
enum AppAppearance {
  /// White surfaces with black text.
  light,

  /// Black surfaces with white text.
  dark,
}

/// User preferences independent of Flutter and platform storage.
class AppSettings extends Equatable {
  /// Creates preferences, defaulting to Spanish and light appearance.
  const new({
    this.language = AppLanguage.spanish,
    this.appearance = AppAppearance.light,
  });

  /// The preferred interface language.
  final AppLanguage language;

  /// The preferred appearance.
  final AppAppearance appearance;

  /// Returns preferences with the supplied fields replaced.
  AppSettings copyWith({AppLanguage? language, AppAppearance? appearance}) =>
      AppSettings(
        language: language ?? this.language,
        appearance: appearance ?? this.appearance,
      );

  @override
  List<Object> get props => [language, appearance];
}
