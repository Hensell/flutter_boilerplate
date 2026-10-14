import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_item.dart';

/// Feature-specific item presentation using the shared design system.
class {{name.pascalCase()}}ItemTile extends StatelessWidget {
  /// Creates an item row.
  const new({required this.item, super.key});

  /// Domain item to display.
  final {{name.pascalCase()}}Item item;

  @override
  Widget build(BuildContext context) => AppListTile(title: item.label);
}
