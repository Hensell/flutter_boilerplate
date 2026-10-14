import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';
import 'package:flutter_boilerplate/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/notes/presentation/cubit/notes_state.dart';
import 'package:flutter_boilerplate/features/notes/presentation/widgets/note_tile.dart';
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
    return AppScreen(
      title: l10n.notesTitle,
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          return AppContent(
            children: [
              AppText(l10n.notesDescription, variant: AppTextStyle.description),
              const AppGap(AppSpacing.section),
              AppTextField(
                controller: _controller,
                enabled: !state.isBusy && state.hasLoaded,
                maxLength: AddNote.maxLength,
                onSubmitted: (_) => _add(),
                label: l10n.noteLabel,
              ),
              const AppGap(AppSpacing.small),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  onPressed: state.isBusy || !state.hasLoaded ? null : _add,
                  icon: Icons.add,
                  label: l10n.addNote,
                ),
              ),
              const AppGap(AppSpacing.section),
              if (state.isBusy) const AppProgress(),
              if (state.failure != null) ...[
                const AppGap(AppSpacing.large),
                AppText(l10n.failureMessage(state.failure!)),
                if (!state.hasLoaded)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      variant: AppButtonStyle.text,
                      onPressed: state.isBusy
                          ? null
                          : () => context.read<NotesCubit>().load(),
                      icon: Icons.refresh,
                      label: l10n.retry,
                    ),
                  ),
              ],
              if (state.hasLoaded && state.notes.isEmpty && !state.isBusy)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.major,
                  ),
                  child: AppText(l10n.notesEmpty),
                ),
              for (final note in state.notes)
                NoteTile(
                  note: note,
                  deleteLabel: l10n.deleteNote,
                  onDelete: state.isBusy
                      ? null
                      : () => context.read<NotesCubit>().remove(note.id),
                ),
            ],
          );
        },
      ),
    );
  }
}
