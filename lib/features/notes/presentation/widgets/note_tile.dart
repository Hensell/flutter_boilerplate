import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/notes/domain/entities/note.dart';

/// Note content and a caller-owned delete action.
class NoteTile extends StatelessWidget {
  /// Creates a note row.
  const new({
    required this.note,
    required this.deleteLabel,
    required this.onDelete,
    super.key,
  });

  /// Note to display.
  final Note note;

  /// Localized delete label.
  final String deleteLabel;

  /// Delete callback; null disables the action.
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppListTile(
        title: note.text,
        trailing: AppIconButton(
          tooltip: deleteLabel,
          onPressed: onDelete,
          icon: Icons.delete_outline,
        ),
      ),
      const AppDivider(spacing: 0),
    ],
  );
}
