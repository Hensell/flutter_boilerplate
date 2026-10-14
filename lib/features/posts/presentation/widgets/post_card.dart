import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/posts/domain/entities/post.dart';

/// Publication composed from shared design system elements.
class PostCard extends StatelessWidget {
  /// Creates a publication card.
  const new({required this.post, super.key});

  /// Publication to display.
  final Post post;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(post.title, variant: AppTextStyle.heading),
      const AppGap(AppSpacing.small),
      AppText(post.body),
      const AppDivider(),
    ],
  );
}
