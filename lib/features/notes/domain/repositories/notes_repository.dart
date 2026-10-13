import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';

/// Contract for a small local collection of example notes.
abstract interface class NotesRepository {
  /// Reads all notes in display order.
  Future<List<Note>> getNotes();

  /// Persists a validated note.
  Future<void> add(Note note);

  /// Removes a note by its stable identifier.
  Future<void> remove(String id);
}
