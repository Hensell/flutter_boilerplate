import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/posts/domain/entities/post.dart';

/// Validates JSON without exposing transport data to presentation.
class PostModel {
  /// Creates a model from a validated entity.
  const new(this.post);

  /// Validates a publication received from the backend.
  factory fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final body = json['body'];
    if (id is! int ||
        id <= 0 ||
        title is! String ||
        title.trim().isEmpty ||
        body is! String) {
      throw const AppFailure(FailureKind.invalidResponse);
    }
    return PostModel(Post(id: id, title: title, body: body));
  }

  /// The validated domain publication.
  final Post post;
}
