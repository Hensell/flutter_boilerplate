import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';

/// Maps notes to a stable storage representation.
class NoteModel {
  /// Creates a model from a domain note.
  const new(this.note);

  /// Validates a decoded note before exposing it to the domain.
  factory fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    final createdAt = json['createdAt'];
    if (id is! String || text is! String || createdAt is! String) {
      throw const AppFailure(FailureKind.invalidData);
    }
    final date = DateTime.tryParse(createdAt);
    if (date == null || id.isEmpty || text.trim().isEmpty) {
      throw const AppFailure(FailureKind.invalidData);
    }
    return NoteModel(Note(id: id, text: text, createdAt: date));
  }

  /// The decoded domain entity.
  final Note note;

  /// Encodes a note without leaking storage types into the domain.
  Map<String, dynamic> toJson() => {
    'id': note.id,
    'text': note.text,
    'createdAt': note.createdAt.toUtc().toIso8601String(),
  };
}
