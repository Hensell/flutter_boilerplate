import 'package:equatable/equatable.dart';

/// A remote publication independent of HTTP and Flutter.
class Post extends Equatable {
  /// Creates a publication.
  const new({required this.id, required this.title, required this.body});

  /// The server-assigned identity.
  final int id;

  /// The publication heading.
  final String title;

  /// The publication content.
  final String body;

  @override
  List<Object> get props => [id, title, body];
}
