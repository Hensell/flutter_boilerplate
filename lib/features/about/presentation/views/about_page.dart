import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';

/// Displays information about the application.
class AboutPage extends StatelessWidget {
  /// Creates the about page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScreen(
      title: l10n.aboutTitle,
      body: Center(child: AppText(l10n.aboutDescription)),
    );
  }
}
