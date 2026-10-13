import 'package:flutter_boilerplate/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_boilerplate/features/posts/domain/entities/post.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';

/// Maps remote models to immutable domain publications.
class PostsRepositoryImpl implements PostsRepository {
  /// Creates a repository with an injected data source.
  const new(this._source);

  final PostsRemoteDataSource _source;

  @override
  Future<List<Post>> fetchPosts() async => List.unmodifiable(
    (await _source.fetchPosts()).map((model) => model.post),
  );
}
