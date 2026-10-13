import 'dart:async';
import 'dart:convert';

import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_boilerplate/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_boilerplate/features/posts/domain/entities/post.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements PostsRepository;

void main() {
  const post = Post(id: 1, title: 'Title', body: 'Body');

  test('repository validates, maps, and limits remote publications', () async {
    final client = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/posts');
        expect(request.url.queryParameters['_limit'], '10');
        return http.Response(
          jsonEncode(
            List.generate(
              12,
              (index) => {'id': index + 1, 'title': 'Title', 'body': 'Body'},
            ),
          ),
          200,
        );
      }),
      baseUri: Uri.parse('https://example.com/'),
      timeout: const Duration(seconds: 1),
    );
    addTearDown(client.close);
    final repository = PostsRepositoryImpl(PostsRemoteDataSource(client));
    final posts = await repository.fetchPosts();
    expect(posts.length, 10);
    expect(posts.first, post);
    expect(() => posts.add(post), throwsUnsupportedError);
  });

  for (final payload in <Object>[
    <String, Object?>{},
    [42],
    [
      {'id': 'wrong', 'title': 'Title', 'body': 'Body'},
    ],
    [
      {'id': 0, 'title': 'Title', 'body': 'Body'},
    ],
    [
      {'id': 1, 'title': '', 'body': 'Body'},
    ],
    [
      {'id': 1, 'title': 'Title', 'body': null},
    ],
  ]) {
    test('rejects an invalid remote contract: $payload', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response(jsonEncode(payload), 200),
        ),
        baseUri: Uri.parse('https://example.com/'),
        timeout: const Duration(seconds: 1),
      );
      addTearDown(client.close);
      final repository = PostsRepositoryImpl(PostsRemoteDataSource(client));
      await expectLater(
        repository.fetchPosts(),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            FailureKind.invalidResponse,
          ),
        ),
      );
    });
  }

  test('cubit retains data on expected and unexpected failures', () async {
    final repository = _MockRepository();
    when(repository.fetchPosts).thenAnswer((_) async => [post]);
    final cubit = PostsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state, const PostsState(posts: [post], hasLoaded: true));
    when(repository.fetchPosts)
        .thenThrow(const AppFailure(FailureKind.network));
    await cubit.load();
    expect(
      cubit.state,
      const PostsState(
        posts: [post],
        hasLoaded: true,
        failure: FailureKind.network,
      ),
    );
    when(repository.fetchPosts).thenThrow(Exception('unexpected'));
    await cubit.load();
    expect(
      cubit.state,
      const PostsState(
        posts: [post],
        hasLoaded: true,
        failure: FailureKind.unexpected,
      ),
    );
  });

  test(
    'ignores overlapping loads and late results after route closure',
    () async {
      final repository = _MockRepository();
      final pending = Completer<List<Post>>();
      when(repository.fetchPosts).thenAnswer((_) => pending.future);
      final cubit = PostsCubit(repository);
      final loading = cubit.load();
      await cubit.load();
      verify(repository.fetchPosts).called(1);
      await cubit.close();
      pending.complete([post]);
      await loading;
      await cubit.load();
      expect(cubit.isClosed, isTrue);
    },
  );
}
