import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{package_name}}/core/errors/failure_localizations.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/repositories/{{name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/presentation/cubit/{{name.snakeCase()}}_cubit.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/presentation/cubit/{{name.snakeCase()}}_state.dart';
import 'package:{{package_name}}/l10n/l10n.dart';

/// Provides route-scoped feature state.
class {{name.pascalCase()}}Page extends StatelessWidget {
  /// Creates the page; register its repository in the composition root.
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) {
      final cubit = {{name.pascalCase()}}Cubit(context.read<{{name.pascalCase()}}Repository>());
      unawaited(cubit.load());
      return cubit;
    },
    child: const {{name.pascalCase()}}View(),
  );
}

/// Displays loading, empty, error, and loaded states.
class {{name.pascalCase()}}View extends StatelessWidget {
  /// Creates the view.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: const Text('{{name.titleCase()}}')),
      body: BlocBuilder<{{name.pascalCase()}}Cubit, {{name.pascalCase()}}State>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.failure != null) Text(l10n.failureMessage(state.failure!)),
            if (!state.isLoading && state.items.isEmpty && state.failure == null)
              const Icon(Icons.inbox_outlined, semanticLabel: 'No items'),
            for (final item in state.items) ListTile(title: Text(item.label)),
            TextButton(onPressed: state.isLoading ? null : () =>
              context.read<{{name.pascalCase()}}Cubit>().load(), child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
