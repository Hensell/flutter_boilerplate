import 'dart:convert';

import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/storage/local_store.dart';
import 'package:flutter_boilerplate/features/settings/data/models/settings_model.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';

/// Reads and writes a versioned preferences document.
class SettingsLocalDataSource {
  /// Creates a data source using the supplied storage contract.
  const new(this._store);

  final LocalStore _store;
  static const _key = 'settings.v1';

  /// Restores a saved model, using defaults for malformed preferences.
  Future<SettingsModel> load() async {
    final raw = await _store.read(_key);
    if (raw == null) return const SettingsModel(AppSettings());
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const SettingsModel(AppSettings());
      }
      return SettingsModel.fromJson(decoded);
    } on FormatException {
      return const SettingsModel(AppSettings());
    }
  }

  /// Saves the model as a JSON document.
  Future<void> save(SettingsModel model) async {
    try {
      await _store.write(_key, jsonEncode(model.toJson()));
    } on AppFailure {
      rethrow;
    } on Exception catch (error) {
      throw AppFailure(FailureKind.storage, cause: error);
    }
  }
}
