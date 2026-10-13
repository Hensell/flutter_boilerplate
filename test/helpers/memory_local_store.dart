import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/storage/local_store.dart';

class MemoryLocalStore implements LocalStore {
  final values = <String, String>{};
  bool failWrites = false;
  bool failReads = false;

  @override
  Future<String?> read(String key) async {
    if (failReads) throw const AppFailure(FailureKind.storage);
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw const AppFailure(FailureKind.storage);
    values[key] = value;
  }
}
