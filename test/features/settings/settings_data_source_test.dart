import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/storage/local_store.dart';
import 'package:flutter_boilerplate/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_boilerplate/features/settings/data/models/settings_model.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStore extends Mock implements LocalStore;

void main() {
  test('maps unexpected storage exceptions to a typed failure', () async {
    final store = _MockStore();
    final cause = Exception('storage unavailable');
    when(() => store.write('settings.v1', any())).thenThrow(cause);
    final source = SettingsLocalDataSource(store);
    await expectLater(
      source.save(const SettingsModel(AppSettings())),
      throwsA(
        isA<AppFailure>()
            .having((failure) => failure.kind, 'kind', FailureKind.storage)
            .having((failure) => failure.cause, 'cause', same(cause)),
      ),
    );
  });
}
