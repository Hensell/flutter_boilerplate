import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/view/app.dart';
import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/main_development.dart' as development;
import 'package:flutter_boilerplate/main_production.dart' as production;
import 'package:flutter_boilerplate/main_staging.dart' as staging;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'helpers/observed_counter_cubit.dart';
import 'helpers/recording_error_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final previousPlatform = SharedPreferencesAsyncPlatform.instance;
    final previousObserver = Bloc.observer;
    final previousErrorHandler = FlutterError.onError;
    final previousPlatformError = PlatformDispatcher.instance.onError;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'settings.v1': '{"language":"en","appearance":"dark"}',
        });
    addTearDown(() {
      SharedPreferencesAsyncPlatform.instance = previousPlatform;
      Bloc.observer = previousObserver;
      FlutterError.onError = previousErrorHandler;
      PlatformDispatcher.instance.onError = previousPlatformError;
    });
  });

  testWidgets('restores dependencies before running an asynchronous builder', (
    tester,
  ) async {
    final previousErrorHandler = FlutterError.onError;
    var built = false;
    final reporter = RecordingErrorReporter();
    await bootstrap(
      (dependencies) async {
        expect(dependencies.config.environment, AppEnvironment.staging);
        expect(dependencies.errorReporter, same(reporter));
        expect(
          dependencies.initialSettings,
          const AppSettings(
            language: AppLanguage.english,
            appearance: AppAppearance.dark,
          ),
        );
        expect(Bloc.observer, isA<AppBlocObserver>());
        built = true;
        return const Directionality(
          textDirection: TextDirection.ltr,
          child: Text('Ready'),
        );
      },
      config: const AppConfig(environment: AppEnvironment.staging),
      errorReporter: reporter,
    );
    expect(built, isTrue);
    FlutterError.onError!(
      FlutterErrorDetails(
        exception: Exception('framework error'),
        stack: StackTrace.current,
      ),
    );
    FlutterError.onError = previousErrorHandler;
    await tester.pump();
    expect(find.text('Ready'), findsOneWidget);
    final cubit = ObservedCounterCubit()
      ..increment()
      ..fail(StateError('example failure'));
    expect(cubit.state, 1);
    await cubit.close();
    expect(
      reporter.records.map((record) => record.$3),
      containsAll(['flutter', 'ObservedCounterCubit']),
    );
  });

  final entryPoints = <AppEnvironment, Future<void> Function()>{
    AppEnvironment.development: development.main,
    AppEnvironment.staging: staging.main,
    AppEnvironment.production: production.main,
  };
  for (final entry in entryPoints.entries) {
    testWidgets('${entry.key.name} entry point starts the configured app', (
      tester,
    ) async {
      final previousErrorHandler = FlutterError.onError;
      await entry.value();
      FlutterError.onError = previousErrorHandler;
      await tester.pumpAndSettle();
      final app = tester.widget<App>(find.byType(App));
      expect(app.dependencies.config.environment, entry.key);
      expect(find.text('Counter'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('Counter'))).brightness,
        Brightness.dark,
      );
      expect(Bloc.observer, isA<AppBlocObserver>());
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}
