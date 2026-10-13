import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/logging/console_error_reporter.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_boilerplate/core/storage/local_store.dart';
import 'package:flutter_boilerplate/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:flutter_boilerplate/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:flutter_boilerplate/features/notes/domain/repositories/notes_repository.dart';
import 'package:flutter_boilerplate/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_boilerplate/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_boilerplate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_boilerplate/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_boilerplate/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/domain/repositories/settings_repository.dart';
import 'package:http/http.dart' as http;

/// Composition root for domain contracts and environment configuration.
class AppDependencies {
  /// Creates injectable dependencies, including restored user preferences.
  const new({
    required this.config,
    required this.apiClient,
    required this.postsRepository,
    required this.errorReporter,
    required this.notesRepository,
    required this.settingsRepository,
    required this.initialSettings,
    this.initialSettingsFailure,
  });

  /// Build environment configuration.
  final AppConfig config;

  /// The shared client whose connections are released with the app.
  final ApiClient apiClient;

  /// Repository for remote publications.
  final PostsRepository postsRepository;

  /// Replaceable reporting destination for this environment.
  final ErrorReporter errorReporter;

  /// Repository shared by notes screens.
  final NotesRepository notesRepository;

  /// Repository used by application preferences.
  final SettingsRepository settingsRepository;

  /// Preferences restored before the first rendered frame.
  final AppSettings initialSettings;

  /// A recoverable startup storage failure shown in settings.
  final FailureKind? initialSettingsFailure;

  /// Releases resources owned by this dependency graph.
  void dispose() => apiClient.close();

  /// Builds production adapters from an injected storage implementation.
  static Future<AppDependencies> create({
    required LocalStore store,
    required AppConfig config,
    http.Client? httpClient,
    ErrorReporter errorReporter = const ConsoleErrorReporter(),
  }) async {
    final settingsRepository = SettingsRepositoryImpl(
      SettingsLocalDataSource(store),
    );
    var initialSettings = const AppSettings();
    FailureKind? initialSettingsFailure;
    try {
      initialSettings = await settingsRepository.load();
    } on AppFailure catch (error) {
      initialSettingsFailure = error.kind;
    }
    final apiClient = ApiClient(
      client: httpClient ?? http.Client(),
      baseUri: Uri.parse(config.apiBaseUrl),
      timeout: config.requestTimeout,
    );
    return AppDependencies(
      config: config,
      apiClient: apiClient,
      postsRepository: PostsRepositoryImpl(PostsRemoteDataSource(apiClient)),
      errorReporter: errorReporter,
      notesRepository: NotesRepositoryImpl(NotesLocalDataSource(store)),
      settingsRepository: settingsRepository,
      initialSettings: initialSettings,
      initialSettingsFailure: initialSettingsFailure,
    );
  }
}
