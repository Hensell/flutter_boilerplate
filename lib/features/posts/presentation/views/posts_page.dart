import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_boilerplate/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_boilerplate/features/posts/presentation/widgets/post_card.dart';
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
      builder: (context, state) => AppScreen(
        title: l10n.postsTitle,
        actions: [
          AppIconButton(
            tooltip: l10n.refreshPosts,
            onPressed: state.isLoading
                ? null
                : () => context.read<PostsCubit>().load(),
            icon: Icons.refresh,
          ),
        ],
        body: AppContent(
          maxWidth: AppLayout.readingWidth,
          children: [
            AppText(l10n.postsDescription, variant: AppTextStyle.description),
            const AppGap(AppSpacing.section),
            if (state.isLoading) ...[
              AppProgress(label: l10n.loadingPosts),
              const AppGap(AppSpacing.section),
            ],
            if (state.failure != null) ...[
              AppText(l10n.failureMessage(state.failure!)),
              const AppGap(AppSpacing.small),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  variant: AppButtonStyle.text,
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<PostsCubit>().load(),
                  icon: Icons.refresh,
                  label: l10n.retry,
                ),
              ),
              const AppGap(AppSpacing.section),
            ],
            if (state.hasLoaded && state.posts.isEmpty && !state.isLoading)
              AppText(l10n.postsEmpty),
            for (final post in state.posts) PostCard(post: post),
          ],
        ),
      ),
    );
  }
}
