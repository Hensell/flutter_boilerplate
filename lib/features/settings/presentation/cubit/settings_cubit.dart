import 'package:bloc/bloc.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';

/// Applies persisted preferences across routes without recreating the router.
class SettingsCubit extends Cubit<SettingsState> {
  /// Creates the cubit with preferences already restored at startup.
  new({
    required this._repository,
    required AppSettings initialSettings,
    FailureKind? initialFailure,
  }) : super(SettingsState(settings: initialSettings, failure: initialFailure));

  final SettingsRepository _repository;

  /// Saves and applies the requested interface language.
  Future<void> changeLanguage(AppLanguage language) =>
      _save(state.settings.copyWith(language: language));

  /// Saves and applies the requested monochrome appearance.
  Future<void> changeAppearance(AppAppearance appearance) =>
      _save(state.settings.copyWith(appearance: appearance));

  Future<void> _save(AppSettings next) async {
    if (state.isSaving || next == state.settings) return;
    final previous = state.settings;
    emit(SettingsState(settings: previous, isSaving: true));
    try {
      await _repository.save(next);
      if (isClosed) return;
      emit(SettingsState(settings: next));
    } on AppFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      if (isClosed) return;
      emit(SettingsState(settings: previous, failure: error.kind));
    }
  }
}
