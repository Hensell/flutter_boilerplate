import 'package:flutter_boilerplate/features/posts/domain/entities/post.dart';

/// Contract for reading remote publications.
abstract interface class PostsRepository {
  /// Reads a limited list of publications.
  Future<List<Post>> fetchPosts();
}
