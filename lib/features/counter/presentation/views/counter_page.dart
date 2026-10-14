import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/counter/counter.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

export '../widgets/counter_text.dart';

/// Provides the counter cubit to the counter screen.
class CounterPage extends StatelessWidget {
  /// Creates this widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

/// Displays the counter and its controls.
class CounterView extends StatelessWidget {
  /// Creates this widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScreen(
      title: l10n.counterAppBarTitle,
      actions: [
        AppIconButton(
          tooltip: l10n.notesTitle,
          onPressed: () => context.push('/notes'),
          icon: Icons.notes_outlined,
        ),
        AppIconButton(
          tooltip: l10n.settingsTitle,
          onPressed: () => context.push('/settings'),
          icon: Icons.settings_outlined,
        ),
        AppIconButton(
          tooltip: l10n.aboutTitle,
          onPressed: () => context.push('/about'),
          icon: Icons.info_outline,
        ),
      ],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CounterText(),
            const AppGap(AppSpacing.section),
            AppButton(
              variant: AppButtonStyle.secondary,
              onPressed: () => context.push('/posts'),
              icon: Icons.cloud_outlined,
              label: l10n.postsTitle,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppFloatingAction(
            heroTag: 'increment',
            onPressed: () => context.read<CounterCubit>().increment(),
            icon: Icons.add,
          ),
          const AppGap(AppSpacing.small),
          AppFloatingAction(
            heroTag: 'decrement',
            onPressed: () => context.read<CounterCubit>().decrement(),
            icon: Icons.remove,
          ),
        ],
      ),
    );
  }
}
