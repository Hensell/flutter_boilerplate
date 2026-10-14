import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';

/// Language and appearance controls independent of state management.
class SettingsChoices extends StatelessWidget {
  /// Creates preference controls.
  const new({
    required this.settings,
    required this.enabled,
    required this.onAppearanceChanged,
    required this.onLanguageChanged,
    super.key,
  });

  /// Selected preferences.
  final AppSettings settings;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Appearance selection callback.
  final ValueChanged<AppAppearance> onAppearanceChanged;

  /// Language selection callback.
  final ValueChanged<AppLanguage> onLanguageChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.appearanceTitle, variant: AppTextStyle.heading),
        const AppGap(AppSpacing.medium),
        RadioGroup<AppAppearance>(
          groupValue: settings.appearance,
          onChanged: (value) {
            if (value != null && enabled) {
              onAppearanceChanged(value);
            }
          },
          child: Column(
            children: [
              AppRadioTile<AppAppearance>(
                value: AppAppearance.light,
                label: l10n.lightTheme,
                icon: Icons.light_mode_outlined,
                enabled: enabled,
              ),
              AppRadioTile<AppAppearance>(
                value: AppAppearance.dark,
                label: l10n.darkTheme,
                icon: Icons.dark_mode_outlined,
                enabled: enabled,
              ),
            ],
          ),
        ),
        const AppDivider(spacing: AppSpacing.divider),
        AppText(l10n.languageTitle, variant: AppTextStyle.heading),
        const AppGap(AppSpacing.medium),
        RadioGroup<AppLanguage>(
          groupValue: settings.language,
          onChanged: (value) {
            if (value != null && enabled) {
              onLanguageChanged(value);
            }
          },
          child: Column(
            children: [
              AppRadioTile<AppLanguage>(
                value: AppLanguage.spanish,
                label: 'Español',
                enabled: enabled,
              ),
              AppRadioTile<AppLanguage>(
                value: AppLanguage.english,
                label: 'English',
                enabled: enabled,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
