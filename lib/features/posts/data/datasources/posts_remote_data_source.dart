import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/features/posts/data/models/post_model.dart';

/// Reads the remote example list through the shared HTTP client.
class PostsRemoteDataSource {
  /// Creates a source with an injected API client.
  const new(this._client);

  final ApiClient _client;

  /// Fetches and validates at most ten publications from the example endpoint.
  Future<List<PostModel>> fetchPosts() async {
    final data = await _client.getJson(
      'posts',
      queryParameters: {'_limit': '10'},
    );
    if (data is! List<dynamic>) {
      throw const AppFailure(FailureKind.invalidResponse);
    }
    return data.take(10).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const AppFailure(FailureKind.invalidResponse);
      }
      return PostModel.fromJson(item);
    }).toList();
  }
}
