import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';

/// Preferences and the current persistence operation.
class SettingsState extends Equatable {
  /// Creates a state retaining the last successfully saved preferences.
  const new({required this.settings, this.isSaving = false, this.failure});

  /// The preferences applied throughout the app.
  final AppSettings settings;

  /// Whether a preferences write is in progress.
  final bool isSaving;

  /// The last persistence failure, if any.
  final FailureKind? failure;

  @override
  List<Object?> get props => [settings, isSaving, failure];
}
