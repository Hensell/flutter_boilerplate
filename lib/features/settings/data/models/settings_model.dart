import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';

/// Converts persisted preference values into domain settings.
class SettingsModel {
  /// Creates a persistence model for settings.
  const new(this.settings);

  /// Reads known values and falls back safely for obsolete values.
  factory fromJson(Map<String, dynamic> json) => SettingsModel(
    AppSettings(
      language: json['language'] == 'en'
          ? AppLanguage.english
          : AppLanguage.spanish,
      appearance: json['appearance'] == 'dark'
          ? AppAppearance.dark
          : AppAppearance.light,
    ),
  );

  /// The decoded domain preferences.
  final AppSettings settings;

  /// Serializes stable values rather than enum indices.
  Map<String, dynamic> toJson() => {
    'language': settings.language.code,
    'appearance': settings.appearance.name,
  };
}
