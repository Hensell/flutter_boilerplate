import 'package:bloc/bloc.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_state.dart';

/// Coordinates remote publications without depending on HTTP details.
class PostsCubit extends Cubit<PostsState> {
  /// Creates a route-scoped cubit with an injected repository.
  new(this._repository) : super(const PostsState());

  final PostsRepository _repository;

  /// Loads or refreshes publications while preventing overlapping requests.
  Future<void> load() async {
    if (state.isLoading || isClosed) return;
    final previous = state;
    emit(
      PostsState(
        posts: previous.posts,
        hasLoaded: previous.hasLoaded,
        isLoading: true,
      ),
    );
    try {
      final posts = await _repository.fetchPosts();
      if (isClosed) return;
      emit(PostsState(posts: posts, hasLoaded: true));
    } on AppFailure catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        PostsState(
          posts: previous.posts,
          hasLoaded: previous.hasLoaded,
          failure: error.kind,
        ),
      );
    } on Exception catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        PostsState(
          posts: previous.posts,
          hasLoaded: previous.hasLoaded,
          failure: FailureKind.unexpected,
        ),
      );
    }
  }
}
