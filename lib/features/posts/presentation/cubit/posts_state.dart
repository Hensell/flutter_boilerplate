import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/posts/domain/entities/post.dart';

/// Remote publications and their current loading operation.
class PostsState extends Equatable {
  /// Creates state retaining previously loaded publications during retries.
  const new({
    this.posts = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.failure,
  });

  /// The last successfully loaded publications.
  final List<Post> posts;

  /// Whether a remote request is in progress.
  final bool isLoading;

  /// Whether a request has completed successfully.
  final bool hasLoaded;

  /// The last request failure, if any.
  final FailureKind? failure;

  @override
  List<Object?> get props => [posts, isLoading, hasLoaded, failure];
}
