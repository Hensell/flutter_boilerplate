/// Build environments supported by the application.
enum AppEnvironment {
  /// Local development environment.
  development,

  /// Pre-production validation environment.
  staging,

  /// Release environment.
  production,
}

/// Immutable environment configuration supplied at startup.
class AppConfig {
  /// Creates configuration; the example endpoint can be overridden per build.
  const new({
    required this.environment,
    this.apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://jsonplaceholder.typicode.com/',
    ),
    this.requestTimeout = const Duration(
      seconds: int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 15),
    ),
  });

  /// The running build environment.
  final AppEnvironment environment;

  /// The backend endpoint, overridden with a build-time Dart define.
  final String apiBaseUrl;

  /// Deadline for receiving the full HTTP response.
  final Duration requestTimeout;

  /// Whether framework errors and state changes are shown during development.
  bool get isDevelopment => environment == AppEnvironment.development;
}
