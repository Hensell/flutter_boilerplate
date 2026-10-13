import 'package:equatable/equatable.dart';

/// An immutable note independent of storage and UI frameworks.
class Note extends Equatable {
  /// Creates a note.
  const new({required this.id, required this.text, required this.createdAt});

  /// The stable identifier used for deletion.
  final String id;

  /// The validated note text.
  final String text;

  /// When the note was created.
  final DateTime createdAt;

  @override
  List<Object> get props => [id, text, createdAt];
}
