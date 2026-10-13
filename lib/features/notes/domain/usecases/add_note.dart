import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';

/// Validates note content and creates its identity before persistence.
class AddNote {
  /// Creates an operation with injectable identity and time providers.
  const new({
    required this._repository,
    required this._createId,
    required this._now,
  });

  /// Maximum number of characters allowed in a note.
  static const maxLength = 280;

  final NotesRepository _repository;
  final String Function() _createId;
  final DateTime Function() _now;

  /// Saves trimmed, non-empty content within the note length limit.
  Future<void> call(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.runes.length > maxLength) {
      throw const AppFailure(FailureKind.invalidNote);
    }
    await _repository.add(
      Note(id: _createId(), text: trimmed, createdAt: _now().toUtc()),
    );
  }
}
