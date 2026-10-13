/// Minimal storage contract used by local data sources.
abstract interface class LocalStore {
  /// Reads a string, or returns null when the key does not exist.
  Future<String?> read(String key);

  /// Persists a string under the supplied key.
  Future<void> write(String key, String value);
}
