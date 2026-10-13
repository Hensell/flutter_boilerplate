import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';
import 'package:flutter_boilerplate/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_state.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';
import 'package:uuid/uuid.dart';

/// Provides route-scoped state for the example notes feature.
class NotesPage extends StatelessWidget {
  /// Creates the notes page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<NotesRepository>();
    return BlocProvider(
      create: (_) {
        final cubit = NotesCubit(
          repository: repository,
          addNote: AddNote(
            repository: repository,
            createId: const Uuid().v4,
            now: DateTime.now,
          ),
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const NotesView(),
    );
  }
}

/// Displays a persistent collection and its add/delete controls.
class NotesView extends StatefulWidget {
  /// Creates the notes view.
  const new({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final cubit = context.read<NotesCubit>();
    if (cubit.state.isBusy) return;
    await cubit.add(_controller.text);
    if (!mounted || cubit.state.failure != null) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesTitle)),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    l10n.notesDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    enabled: !state.isBusy && state.hasLoaded,
                    maxLength: AddNote.maxLength,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    decoration: InputDecoration(labelText: l10n.noteLabel),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: state.isBusy || !state.hasLoaded ? null : _add,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addNote),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.isBusy) const LinearProgressIndicator(),
                  if (state.failure != null) ...[
                    const SizedBox(height: 16),
                    Text(l10n.failureMessage(state.failure!)),
                    if (!state.hasLoaded)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: state.isBusy
                              ? null
                              : () => context.read<NotesCubit>().load(),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ),
                  ],
                  if (state.hasLoaded && state.notes.isEmpty && !state.isBusy)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(l10n.notesEmpty),
                    ),
                  for (final note in state.notes) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(note.text),
                      trailing: IconButton(
                        tooltip: l10n.deleteNote,
                        onPressed: state.isBusy
                            ? null
                            : () => context.read<NotesCubit>().remove(note.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
