import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';

/// Notes plus the current operation, retaining data during failures.
class NotesState extends Equatable {
  /// Creates a notes state.
  const new({
    this.notes = const [],
    this.isBusy = false,
    this.hasLoaded = false,
    this.failure,
  });

  /// The last successfully loaded collection.
  final List<Note> notes;

  /// Whether a load or mutation is in progress.
  final bool isBusy;

  /// Whether the first successful load has completed.
  final bool hasLoaded;

  /// The last operation failure.
  final FailureKind? failure;

  @override
  List<Object?> get props => [notes, isBusy, hasLoaded, failure];
}
