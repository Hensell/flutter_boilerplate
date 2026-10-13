import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/counter/counter.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.counterAppBarTitle),
        actions: [
          IconButton(
            tooltip: l10n.notesTitle,
            onPressed: () => context.push('/notes'),
            icon: const Icon(Icons.notes_outlined),
          ),
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.aboutTitle,
            onPressed: () => context.push('/about'),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CounterText(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push('/posts'),
              icon: const Icon(Icons.cloud_outlined),
              label: Text(l10n.postsTitle),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

/// Displays the current counter value.
class CounterText extends StatelessWidget {
  /// Creates this widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = context.select<CounterCubit, int>((cubit) => cubit.state);
    return Text('$count', style: theme.textTheme.displayLarge);
  }
}
