import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_boilerplate/features/settings/presentation/widgets/settings_choices.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';

/// Lets users change persisted language and monochrome appearance.
class SettingsPage extends StatelessWidget {
  /// Creates the settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScreen(
      title: l10n.settingsTitle,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          return AppContent(
            children: [
              AppText(
                l10n.settingsDescription,
                variant: AppTextStyle.description,
              ),
              const AppGap(AppSpacing.major),
              SettingsChoices(
                settings: state.settings,
                enabled: !state.isSaving,
                onAppearanceChanged: (value) =>
                    unawaited(cubit.changeAppearance(value)),
                onLanguageChanged: (value) =>
                    unawaited(cubit.changeLanguage(value)),
              ),
              const AppGap(AppSpacing.section),
              if (state.isSaving)
                const AppProgress()
              else if (state.failure != null)
                AppText(
                  l10n.failureMessage(state.failure!),
                  semanticsLabel: l10n.failureMessage(state.failure!),
                )
              else
                AppText(l10n.preferencesSaved, variant: AppTextStyle.caption),
            ],
          );
        },
      ),
    );
  }
}
