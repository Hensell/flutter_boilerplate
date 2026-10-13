import 'package:flutter_boilerplate/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_boilerplate/features/settings/data/models/settings_model.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/domain/repositories/settings_repository.dart';

/// Persists domain preferences through a local data source.
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates a repository with an injected data source.
  const new(this._source);

  final SettingsLocalDataSource _source;

  @override
  Future<AppSettings> load() async => (await _source.load()).settings;

  @override
  Future<void> save(AppSettings settings) =>
      _source.save(SettingsModel(settings));
}
