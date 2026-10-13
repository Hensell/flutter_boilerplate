import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:flutter_boilerplate/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';
import 'package:flutter_boilerplate/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_local_store.dart';

class _DelayedRepository implements NotesRepository {
  final completer = Completer<List<Note>>();

  @override
  Future<List<Note>> getNotes() => completer.future;

  @override
  Future<void> add(Note note) async {}

  @override
  Future<void> remove(String id) async {}
}

void main() {
  late MemoryLocalStore store;
  late NotesRepositoryImpl repository;
  late AddNote addNote;
  final date = DateTime.utc(2026, 10, 13);
  var id = 0;

  setUp(() {
    store = MemoryLocalStore();
    repository = NotesRepositoryImpl(NotesLocalDataSource(store));
    id = 0;
    addNote = AddNote(
      repository: repository,
      createId: () => 'note-${id++}',
      now: () => date,
    );
  });

  test('validates and trims before persisting a domain note', () async {
    await addNote('  My idea  ');
    expect(await repository.getNotes(), [
      Note(id: 'note-0', text: 'My idea', createdAt: date),
    ]);
    for (final text in ['  ', List.filled(281, 'a').join()]) {
      await expectLater(
        addNote(text),
        throwsA(
          isA<AppFailure>().having(
            (error) => error.kind,
            'kind',
            FailureKind.invalidNote,
          ),
        ),
      );
    }
    expect((await repository.getNotes()).length, 1);
  });

  test(
    'serializes concurrent additions and restores a new repository',
    () async {
      await Future.wait([addNote('First'), addNote('Second')]);
      final restored = NotesRepositoryImpl(NotesLocalDataSource(store));
      expect((await restored.getNotes()).map((note) => note.text), [
        'Second',
        'First',
      ]);
      await restored.remove('note-0');
      expect((await repository.getNotes()).map((note) => note.text), [
        'Second',
      ]);
    },
  );

  test('reports corrupt data without overwriting it', () async {
    store.values['notes.v1'] = '{broken';
    await expectLater(
      addNote('New note'),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.kind,
          'kind',
          FailureKind.invalidData,
        ),
      ),
    );
    expect(store.values['notes.v1'], '{broken');
  });

  test('a failed mutation does not poison subsequent writes', () async {
    store.failWrites = true;
    await expectLater(addNote('Failed'), throwsA(isA<AppFailure>()));
    store.failWrites = false;
    await addNote('Retry');
    expect((await repository.getNotes()).single.text, 'Retry');
  });

  blocTest<NotesCubit, NotesState>(
    'preserves loaded notes when a save fails',
    build: () => NotesCubit(repository: repository, addNote: addNote),
    act: (cubit) async {
      await cubit.load();
      await cubit.add('Existing');
      store.failWrites = true;
      await cubit.add('Fails');
    },
    expect: () => [
      const NotesState(isBusy: true),
      const NotesState(hasLoaded: true),
      const NotesState(hasLoaded: true, isBusy: true),
      NotesState(
        hasLoaded: true,
        notes: [Note(id: 'note-0', text: 'Existing', createdAt: date)],
      ),
      NotesState(
        hasLoaded: true,
        isBusy: true,
        notes: [Note(id: 'note-0', text: 'Existing', createdAt: date)],
      ),
      NotesState(
        hasLoaded: true,
        failure: FailureKind.storage,
        notes: [Note(id: 'note-0', text: 'Existing', createdAt: date)],
      ),
    ],
    errors: () => [isA<AppFailure>()],
  );

  test('does not emit after the route closes during a load', () async {
    final delayed = _DelayedRepository();
    final cubit = NotesCubit(
      repository: delayed,
      addNote: AddNote(
        repository: delayed,
        createId: () => 'id',
        now: () => date,
      ),
    );
    final loading = cubit.load();
    await cubit.close();
    delayed.completer.complete([]);
    await loading;
    expect(cubit.isClosed, isTrue);
  });
}
