import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/app/di/app_dependencies.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/logging/app_error_handlers.dart';
import 'package:flutter_boilerplate/core/logging/console_error_reporter.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';
import 'package:flutter_boilerplate/core/logging/error_reporting.dart';
import 'package:flutter_boilerplate/core/storage/preferences_local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Observes state changes and unexpected errors across blocs and cubits.
class AppBlocObserver extends BlocObserver {
  /// Creates an observer; state logging is restricted to development.
  const new({
    required this._reporting,
    this._logChanges = false,
    this._writer = log,
  });

  final ErrorReporting _reporting;
  final bool _logChanges;
  final ErrorLogWriter _writer;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (_logChanges) _writer('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (error is! AppFailure || !error.isExpected) {
      _reporting.capture(
        error,
        stackTrace,
        context: bloc.runtimeType.toString(),
      );
    }
    super.onError(bloc, error, stackTrace);
  }
}

/// Installs global error hooks and restores dependencies before rendering.
Future<void> bootstrap(
  FutureOr<Widget> Function(AppDependencies) builder, {
  required AppConfig config,
  ErrorReporter? errorReporter,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final reporter = errorReporter ?? const ConsoleErrorReporter();
  final reporting = ErrorReporting(reporter: reporter);
  AppErrorHandlers.install(
    reporting: reporting,
    presentFlutterErrors: config.isDevelopment,
  );
  Bloc.observer = AppBlocObserver(
    reporting: reporting,
    logChanges: config.isDevelopment,
  );
  final dependencies = await AppDependencies.create(
    store: PreferencesLocalStore(SharedPreferencesAsync()),
    config: config,
    errorReporter: reporter,
  );
  runApp(await builder(dependencies));
}
