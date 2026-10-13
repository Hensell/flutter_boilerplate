import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_boilerplate/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/create_dependencies.dart';
import '../../helpers/memory_local_store.dart';

void main() {
  late MemoryLocalStore store;
  late SettingsRepositoryImpl repository;
  const initial = AppSettings();
  const changed = AppSettings(
    language: AppLanguage.english,
    appearance: AppAppearance.dark,
  );

  setUp(() {
    store = MemoryLocalStore();
    repository = SettingsRepositoryImpl(SettingsLocalDataSource(store));
  });

  test(
    'a storage failure at startup still creates usable dependencies',
    () async {
      store.failReads = true;
      final dependencies = await createDependencies(store);
      expect(dependencies.initialSettings, initial);
      expect(dependencies.initialSettingsFailure, FailureKind.storage);
    },
  );

  test('restores preferences from a new repository instance', () async {
    expect(await repository.load(), initial);
    await repository.save(changed);
    final restored = SettingsRepositoryImpl(SettingsLocalDataSource(store));
    expect(await restored.load(), changed);
  });

  test('malformed and obsolete preferences safely use defaults', () async {
    for (final value in [
      '{broken',
      '[]',
      '{"language":"xx","appearance":"old"}',
    ]) {
      store.values['settings.v1'] = value;
      expect(await repository.load(), initial);
    }
  });

  blocTest<SettingsCubit, SettingsState>(
    'keeps the last saved appearance when persistence fails',
    build: () {
      store.failWrites = true;
      return SettingsCubit(repository: repository, initialSettings: initial);
    },
    act: (cubit) => cubit.changeAppearance(AppAppearance.dark),
    expect: () => [
      const SettingsState(settings: initial, isSaving: true),
      const SettingsState(settings: initial, failure: FailureKind.storage),
    ],
    errors: () => [isA<AppFailure>()],
  );

  test('changing language preserves the chosen appearance', () async {
    final cubit = SettingsCubit(
      repository: repository,
      initialSettings: initial,
    );
    await cubit.changeAppearance(AppAppearance.dark);
    await cubit.changeLanguage(AppLanguage.english);
    expect(cubit.state.settings, changed);
    expect(await repository.load(), changed);
    await cubit.close();
  });
}
