import 'package:bloc/bloc.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';
import 'package:flutter_boilerplate/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_state.dart';

/// Coordinates note operations without knowing storage or platform details.
class NotesCubit extends Cubit<NotesState> {
  /// Creates a cubit with injected domain dependencies.
  new({required this._repository, required this._addNote})
    : super(const NotesState());

  final NotesRepository _repository;
  final AddNote _addNote;

  /// Restores the persisted collection.
  Future<void> load() => _run(() async {});

  /// Validates, persists, and reloads a note.
  Future<void> add(String text) => _run(() => _addNote(text));

  /// Deletes and reloads a note.
  Future<void> remove(String id) => _run(() => _repository.remove(id));

  Future<void> _run(Future<void> Function() operation) async {
    if (state.isBusy) return;
    final previous = state;
    emit(
      NotesState(
        notes: previous.notes,
        hasLoaded: previous.hasLoaded,
        isBusy: true,
      ),
    );
    try {
      await operation();
      final notes = await _repository.getNotes();
      if (isClosed) return;
      emit(NotesState(notes: notes, hasLoaded: true));
      return;
    } on AppFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      if (isClosed) return;
      emit(
        NotesState(
          notes: previous.notes,
          hasLoaded: previous.hasLoaded,
          failure: error.kind,
        ),
      );
      return;
    }
  }
}
