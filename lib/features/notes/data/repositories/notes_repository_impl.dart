import 'package:flutter_boilerplate/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:flutter_boilerplate/features/notes/data/models/note_model.dart';
import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';

/// Maps local models to domain notes and serializes collection mutations.
class NotesRepositoryImpl implements NotesRepository {
  /// Creates a repository with an injected local data source.
  new(this._source);

  final NotesLocalDataSource _source;
  Future<void> _pending = Future<void>.value();

  @override
  Future<List<Note>> getNotes() async {
    await _pending;
    final models = await _source.read();
    return List.unmodifiable(
      models.map((model) => model.note).toList().reversed,
    );
  }

  @override
  Future<void> add(Note note) => _mutate((notes) => notes.add(NoteModel(note)));

  @override
  Future<void> remove(String id) =>
      _mutate((notes) => notes.removeWhere((model) => model.note.id == id));

  Future<void> _mutate(void Function(List<NoteModel>) update) {
    final operation = _pending.then((_) async {
      final notes = await _source.read();
      update(notes);
      await _source.write(notes);
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }
}
