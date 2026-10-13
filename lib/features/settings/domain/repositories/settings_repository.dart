import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';

/// Contract for restoring and persisting user preferences.
abstract interface class SettingsRepository {
  /// Restores preferences or defaults when no saved values exist.
  Future<AppSettings> load();

  /// Persists the entire preferences snapshot.
  Future<void> save(AppSettings settings);
}
