import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';

/// Provides remote publications state for the route.
class PostsPage extends StatelessWidget {
  /// Creates the publications page.
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) {
      final cubit = PostsCubit(context.read<PostsRepository>());
      unawaited(cubit.load());
      return cubit;
    },
    child: const PostsView(),
  );
}

/// Displays remote loading, empty, error, and loaded states.
class PostsView extends StatelessWidget {
  /// Creates the publications view.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.postsTitle),
          actions: [
            IconButton(
              tooltip: l10n.refreshPosts,
              onPressed: state.isLoading
                  ? null
                  : () => context.read<PostsCubit>().load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.postsDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (state.isLoading) ...[
                  LinearProgressIndicator(semanticsLabel: l10n.loadingPosts),
                  const SizedBox(height: 24),
                ],
                if (state.failure != null) ...[
                  Text(l10n.failureMessage(state.failure!)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<PostsCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (state.hasLoaded && state.posts.isEmpty && !state.isLoading)
                  Text(l10n.postsEmpty),
                for (final post in state.posts) ...[
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(post.body),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
