import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/storage/preferences_local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _MockPreferences extends Mock implements SharedPreferencesAsync;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists and reads through the real preferences API', () async {
    final originalPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    addTearDown(
      () => SharedPreferencesAsyncPlatform.instance = originalPlatform,
    );
    final store = PreferencesLocalStore(SharedPreferencesAsync());
    expect(await store.read('missing'), isNull);
    await store.write('settings', '{"language":"en"}');
    final restoredStore = PreferencesLocalStore(SharedPreferencesAsync());
    expect(await restoredStore.read('settings'), '{"language":"en"}');
  });

  test(
    'a stored value of the wrong type becomes a recoverable failure',
    () async {
      final originalPlatform = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'settings.v1': 42});
      addTearDown(
        () => SharedPreferencesAsyncPlatform.instance = originalPlatform,
      );
      final store = PreferencesLocalStore(SharedPreferencesAsync());
      await expectLater(
        store.read('settings.v1'),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            FailureKind.storage,
          ),
        ),
      );
    },
  );

  test(
    'maps a platform read exception and retains its diagnostic cause',
    () async {
      final preferences = _MockPreferences();
      final cause = PlatformException(code: 'unavailable');
      when(() => preferences.getAll(allowList: {'key'})).thenThrow(cause);
      final store = PreferencesLocalStore(preferences);
      await expectLater(
        store.read('key'),
        throwsA(
          isA<AppFailure>()
              .having((failure) => failure.kind, 'kind', FailureKind.storage)
              .having((failure) => failure.cause, 'cause', same(cause)),
        ),
      );
    },
  );

  test('maps a failed platform write without reporting success', () async {
    final preferences = _MockPreferences();
    final cause = PlatformException(code: 'disk_full');
    when(() => preferences.setString('key', 'value')).thenThrow(cause);
    final store = PreferencesLocalStore(preferences);
    await expectLater(
      store.write('key', 'value'),
      throwsA(
        isA<AppFailure>()
            .having((failure) => failure.kind, 'kind', FailureKind.storage)
            .having((failure) => failure.cause, 'cause', same(cause)),
      ),
    );
    verify(() => preferences.setString('key', 'value')).called(1);
  });
}
