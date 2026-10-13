import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/errors/failure_localizations.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';

/// Lets users change persisted language and monochrome appearance.
class SettingsPage extends StatelessWidget {
  /// Creates the settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    l10n.settingsDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.appearanceTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<AppAppearance>(
                    groupValue: state.settings.appearance,
                    onChanged: (value) {
                      if (value != null && !state.isSaving) {
                        unawaited(cubit.changeAppearance(value));
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<AppAppearance>(
                          value: AppAppearance.light,
                          title: Text(l10n.lightTheme),
                          secondary: const Icon(Icons.light_mode_outlined),
                          enabled: !state.isSaving,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<AppAppearance>(
                          value: AppAppearance.dark,
                          title: Text(l10n.darkTheme),
                          secondary: const Icon(Icons.dark_mode_outlined),
                          enabled: !state.isSaving,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Text(
                    l10n.languageTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<AppLanguage>(
                    groupValue: state.settings.language,
                    onChanged: (value) {
                      if (value != null && !state.isSaving) {
                        unawaited(cubit.changeLanguage(value));
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<AppLanguage>(
                          value: AppLanguage.spanish,
                          title: const Text('Español'),
                          enabled: !state.isSaving,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<AppLanguage>(
                          value: AppLanguage.english,
                          title: const Text('English'),
                          enabled: !state.isSaving,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.isSaving)
                    const LinearProgressIndicator()
                  else if (state.failure != null)
                    Text(
                      l10n.failureMessage(state.failure!),
                      semanticsLabel: l10n.failureMessage(state.failure!),
                    )
                  else
                    Text(
                      l10n.preferencesSaved,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
