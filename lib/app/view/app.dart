import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/app/di/app_dependencies.dart';
import 'package:flutter_boilerplate/app/router/app_router.dart';
import 'package:flutter_boilerplate/app/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_boilerplate/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

/// Composition boundary owning the router and app-wide settings cubit.
class App extends StatefulWidget {
  /// Creates an application with explicit dependencies.
  const new({required this.dependencies, super.key});

  /// The environment and repositories created before rendering.
  final AppDependencies dependencies;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies _dependencies = widget.dependencies;
  late final GoRouter _router = createAppRouter();
  late final SettingsCubit _settingsCubit = SettingsCubit(
    repository: _dependencies.settingsRepository,
    initialSettings: _dependencies.initialSettings,
    initialFailure: _dependencies.initialSettingsFailure,
  );

  @override
  void dispose() {
    _router.dispose();
    unawaited(_settingsCubit.close());
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostsRepository>.value(
          value: _dependencies.postsRepository,
        ),
        RepositoryProvider<ErrorReporter>.value(
          value: _dependencies.errorReporter,
        ),
        RepositoryProvider<AppConfig>.value(value: _dependencies.config),
        RepositoryProvider<NotesRepository>.value(
          value: _dependencies.notesRepository,
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: _dependencies.settingsRepository,
        ),
      ],
      child: BlocProvider.value(
        value: _settingsCubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.settings.appearance == AppAppearance.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            locale: Locale(state.settings.language.code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
