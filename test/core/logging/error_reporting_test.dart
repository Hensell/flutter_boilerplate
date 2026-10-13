import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/logging/app_error_handlers.dart';
import 'package:flutter_boilerplate/core/logging/console_error_reporter.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';
import 'package:flutter_boilerplate/core/logging/error_reporting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/observed_counter_cubit.dart';

class _MockReporter extends Mock implements ErrorReporter;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => registerFallbackValue(StackTrace.current));

  test(
    'console reporter preserves error, stack, and diagnostic context',
    () async {
      final entries = <(String, Object?, StackTrace?)>[];
      final reporter = ConsoleErrorReporter(
        writer: (message, {error, stackTrace}) {
          entries.add((message, error, stackTrace));
        },
      );
      final error = StateError('unexpected');
      final stack = StackTrace.current;
      await reporter.report(error, stack, context: 'posts');
      await reporter.report(error, stack);
      expect(entries.first, ('Application error (posts)', error, stack));
      expect(entries.last.$1, 'Application error (unknown)');
    },
  );

  test('reporter failures go to the fallback without recursion', () async {
    final reporter = _MockReporter();
    final original = Exception('original');
    final stack = StackTrace.current;
    final reporterError = StateError('broken reporter');
    when(() => reporter.report(original, stack, context: 'platform'))
        .thenThrow(reporterError);
    final fallback = <Object?>[];
    ErrorReporting(
      reporter: reporter,
      fallbackWriter: (message, {error, stackTrace}) => fallback.add(error),
    ).capture(original, stack, context: 'platform');
    await Future<void>.delayed(Duration.zero);
    expect(fallback, [reporterError]);
    verify(() => reporter.report(original, stack, context: 'platform'))
        .called(1);
  });

  test(
    'framework and root-isolate hooks preserve originals and handle errors',
    () async {
      final previousFlutter = FlutterError.onError;
      final previousPresenter = FlutterError.presentError;
      final previousPlatform = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = previousFlutter;
        FlutterError.presentError = previousPresenter;
        PlatformDispatcher.instance.onError = previousPlatform;
      });
      final reporter = _MockReporter();
      final error = Exception('framework');
      final platformError = Exception('platform');
      final stack = StackTrace.current;
      when(() => reporter.report(error, stack, context: 'flutter'))
          .thenAnswer((_) async {});
      when(() => reporter.report(platformError, stack, context: 'platform'))
          .thenAnswer((_) async {});
      when(() => reporter.report(error, any(), context: 'flutter'))
          .thenAnswer((_) async {});
      final presented = <FlutterErrorDetails>[];
      FlutterError.presentError = presented.add;
      AppErrorHandlers.install(
        reporting: ErrorReporting(reporter: reporter),
        presentFlutterErrors: true,
      );
      final details = FlutterErrorDetails(exception: error, stack: stack);
      FlutterError.onError!(details);
      expect(
        PlatformDispatcher.instance.onError!(platformError, stack),
        isTrue,
      );
      await Future<void>.delayed(Duration.zero);
      expect(presented, [details]);
      verify(() => reporter.report(error, stack, context: 'flutter')).called(1);
      verify(() => reporter.report(platformError, stack, context: 'platform'))
          .called(1);
      AppErrorHandlers.install(
        reporting: ErrorReporting(reporter: reporter),
        presentFlutterErrors: false,
      );
      FlutterError.onError!(FlutterErrorDetails(exception: error));
      await Future<void>.delayed(Duration.zero);
      expect(presented.length, 1);
    },
  );

  test(
    'observer reports unexpected errors and filters handled domain failures',
    () async {
      final reporter = _MockReporter();
      final logs = <String>[];
      final error = Exception('unexpected');
      final stack = StackTrace.current;
      final cubit = ObservedCounterCubit();
      addTearDown(cubit.close);
      when(() => reporter.report(error, stack, context: 'ObservedCounterCubit'))
          .thenAnswer((_) async {});
      final observer =
          AppBlocObserver(
              reporting: ErrorReporting(reporter: reporter),
              logChanges: true,
              writer: (message, {error, stackTrace}) => logs.add(message),
            )
            ..onChange(cubit, const Change(currentState: 0, nextState: 1))
            ..onError(cubit, error, stack);
      for (final kind in [
        FailureKind.storage,
        FailureKind.invalidNote,
        FailureKind.network,
        FailureKind.timeout,
        FailureKind.server,
      ]) {
        final failure = AppFailure(kind);
        expect(failure.isExpected, isTrue);
        observer.onError(cubit, failure, stack);
      }
      for (final kind in [
        FailureKind.invalidData,
        FailureKind.invalidResponse,
        FailureKind.unexpected,
      ]) {
        final failure = AppFailure(kind);
        expect(failure.isExpected, isFalse);
        when(
          () =>
              reporter.report(failure, stack, context: 'ObservedCounterCubit'),
        ).thenAnswer((_) async {});
        observer.onError(cubit, failure, stack);
        verify(
          () =>
              reporter.report(failure, stack, context: 'ObservedCounterCubit'),
        ).called(1);
      }
      await Future<void>.delayed(Duration.zero);
      expect(logs.single, contains('onChange(ObservedCounterCubit'));
      verify(
        () => reporter.report(error, stack, context: 'ObservedCounterCubit'),
      ).called(1);
    },
  );
}
