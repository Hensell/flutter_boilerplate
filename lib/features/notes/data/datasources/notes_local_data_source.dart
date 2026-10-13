import 'dart:convert';

import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/storage/local_store.dart';
import 'package:flutter_boilerplate/features/notes/data/models/note_model.dart';

/// Stores the small example collection as a versioned JSON document.
class NotesLocalDataSource {
  /// Creates a data source using the supplied store.
  const new(this._store);

  final LocalStore _store;
  static const _key = 'notes.v1';

  /// Reads notes, reporting corrupt data instead of silently overwriting it.
  Future<List<NoteModel>> read() async {
    final raw = await _store.read(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw const AppFailure(FailureKind.invalidData);
      }
      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const AppFailure(FailureKind.invalidData);
        }
        return NoteModel.fromJson(item);
      }).toList();
    } on FormatException catch (error) {
      throw AppFailure(FailureKind.invalidData, cause: error);
    }
  }

  /// Persists a complete notes snapshot.
  Future<void> write(List<NoteModel> notes) => _store.write(
    _key,
    jsonEncode(notes.map((model) => model.toJson()).toList()),
  );
}
