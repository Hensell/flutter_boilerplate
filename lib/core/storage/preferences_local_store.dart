import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/storage/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores small, non-sensitive app data using platform preferences.
class PreferencesLocalStore implements LocalStore {
  /// Creates a store with an injected platform adapter.
  const new(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) async {
    try {
      final values = await _preferences.getAll(allowList: {key});
      final value = values[key];
      if (value != null && value is! String) {
        throw const AppFailure(FailureKind.storage);
      }
      return value as String?;
    } on AppFailure {
      rethrow;
    } on Exception catch (error) {
      throw AppFailure(FailureKind.storage, cause: error);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } on Exception catch (error) {
      throw AppFailure(FailureKind.storage, cause: error);
    }
  }
}
