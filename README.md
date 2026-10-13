# Flutter Boilerplate

Created and maintained by **[Hensell](https://github.com/Hensell)**.
Explore my work at **[hensell.dev](https://hensell.dev)**.

A Very Good CLI starter organized by feature, with BLoC/Cubit, GoRouter,
localization, persisted settings, local notes, remote publications, and a tested
Mason feature generator.

## Features

- Very Good Analysis and Bloc Lint, with required public API documentation.
- Development, staging, and production entry points with explicit environment configuration.
- Spanish and English, with persisted black and white light/dark themes.
- Create, list, and delete local notes with domain validation.
- Remote publications with a configurable HTTP client, timeout, and typed failures.
- A local Mason feature generator with checked templates and behavior tests.
- Injectable console error reporting for Flutter, root-isolate, and Cubit failures.
- Injectable repositories and storage, typed failures, and automated tests.
- Application-owned router and settings Cubit with explicit lifecycle management.

## Run

Flutter 3.47.0 / Dart 3.13 is pinned in `.fvmrc`.
The code uses private initializing-formal parameters: `this._client` exposes the
public argument `client` to callers on this SDK, as described in the
[Dart constructor documentation](https://dart.dev/language/constructors).

```sh
fvm install
fvm flutter pub get
fvm flutter run --flavor development --target lib/main_development.dart
# Web
fvm flutter run -d chrome --target lib/main_development.dart
```

Other entry points: `lib/main_staging.dart` and `lib/main_production.dart`.
Each supplies an `AppConfig` with its environment.

The counter toolbar opens Notes, Settings, and About; the Publications button
opens the remote example. Routes: `/`, `/notes`,
`/settings`, `/posts`, and `/about`.

## Architecture

```text
lib/
  app/
    di/                 # Composition root
    router/             # Navigation
    theme/              # Monochrome Material themes
    view/               # Providers and application-wide preferences
  core/
    config/             # Immutable environment configuration
    errors/             # Typed failures and localized messages
    logging/            # Error reporting and global error handlers
    network/            # HTTP client and response validation
    storage/            # Storage contract and preferences adapter
  features/
    notes/
      domain/
        entities/
        repositories/   # Contracts independent of Flutter
        usecases/       # Validation and note creation
      data/
        datasources/
        models/         # JSON mapping
        repositories/   # Contract implementations
      presentation/
        cubit/
        views/
    settings/
      domain/
      data/
      presentation/
    posts/
      domain/
      data/
      presentation/
    counter/            # Simple Cubit example
    about/
  l10n/
```

Notes follows `View → Cubit → AddNote → NotesRepository → DataSource`.
The use case validates and trims text, with injectable identity and time providers.
Simple queries and settings call repository contracts directly instead of adding
use cases that only forward a method call.

`AppDependencies` connects adapters. `RepositoryProvider` exposes contracts,
and route-scoped `BlocProvider` instances own feature Cubits. `App` owns the
settings Cubit and router: language and theme changes preserve the navigation
stack and state of previous routes.

## Persistence and failures

`SharedPreferencesAsync` stores preferences and the small example collection
locally on supported mobile, web, and desktop platforms. Notes use versioned
JSON. For larger collections or transactions, replace the notes adapter with
a database while retaining the repository contract.

- Preferences are restored before the first frame.
- Unknown or malformed preferences fall back to defaults.
- Startup storage failures still allow the app to open and appear in Settings.
- Failed preference writes retain the last applied values.
- Corrupt notes produce a typed failure and are not silently overwritten.
- Notes mutations are serialized to preserve concurrent changes.
- Cubits retain data during operations and check for closure before emitting
  states after asynchronous work.
- Presentation translates failure categories without exposing plugin errors.

## Validate

```sh
fvm dart format --output=none --set-exit-if-changed lib test
fvm flutter analyze
fvm dart run bloc_tools:bloc lint .
fvm dart pub global activate very_good_cli 1.5.0
./tool/test.sh
fvm flutter build web --target lib/main_production.dart
```

The local test script and Very Good Workflows CI enforce **100% line coverage**
with `--collect-coverage-from all` and randomized test ordering. Coverage includes
all three entry points, bootstrap, and the preferences adapter. Only generated
translations and declaration-only storage, logging, and domain repository
contracts are excluded; no handwritten executable code is excluded.

The preferences adapter is tested using the real `SharedPreferencesAsync` API
with the plugin's in-memory platform implementation. Platform errors use mocks,
and original platform instances, observers, and error handlers are restored
between tests. This measures app code, not native plugin internals or branch coverage.

Tests cover domain validation, persistence, corrupt data, write failures,
concurrent mutations, navigation, Cubit closure, HTTP deadlines and failures,
and global error reporting with fallback handling. Widget tests cover language
and theme changes, preference restoration, notes operations, and six screen
sizes with enlarged text and keyboard space.

Latest validated baseline: **67 passing app tests**, **581/581 executable lines
covered across 42 files**, and **70 passing tests** when the generated feature is
included. Formatting, both linters, and the development web build passed.
These counts describe the current baseline; rerun the commands after changes.
Native builds have not been validated.

Edit translations in `lib/l10n/arb/`, then regenerate them:

```sh
fvm flutter gen-l10n
```

UI previews: [light settings](docs/previews/settings-light.png),
[dark settings](docs/previews/settings-dark.png),
[notes](docs/previews/notes-dark.png), and
[remote publications](docs/previews/posts-light.png).

## Remote example

The Publications button on the counter opens `/posts`. The example uses
[JSONPlaceholder](https://jsonplaceholder.typicode.com/) and reads up to ten posts.
The flow is `PostsView → PostsCubit → PostsRepository → RemoteDataSource → ApiClient`.
Domain entities contain no HTTP or Flutter types. Tests use controlled HTTP
responses rather than depending on internet access.

Each entry point supplies `AppConfig`. Override the backend and deadline per build:

```sh
fvm flutter run -d chrome -t lib/main_staging.dart \
  --dart-define=API_BASE_URL=https://jsonplaceholder.typicode.com/ \
  --dart-define=API_TIMEOUT_SECONDS=15
```

Endpoints must use HTTP or HTTPS, with a positive deadline. The shared client
sends JSON accept headers, validates JSON, preserves an API path prefix by
rejecting traversal segments, maps network/status/format errors, and aborts
supported transports when the full-response deadline expires. `App` releases the
owned HTTP client when disposed. Android declares internet
access for release builds too; macOS debug and release entitlements allow outgoing
connections while retaining the app sandbox. The example endpoint uses HTTPS.

## Generate a feature

Install the pinned Mason CLI once, then generate a feature in this project:

```sh
fvm dart pub global activate mason_cli 0.1.4
./tool/make_feature.sh inventory
```

The wrapper reads the package name from `pubspec.yaml`, validates the name, and
refuses to overwrite an existing feature. It generates domain entities/contracts,
source models, a data source, repository implementation, Cubit/state, page/view,
exports, and tests. Register the repository in `AppDependencies`, expose it through
`RepositoryProvider`, and add its page to the router following the generated README.
The source is initially empty; replace its internals with the app's local or remote
adapter. Use cases are added when business rules require them.

```sh
./tool/check_feature_template.sh
```

This renders the actual brick in a temporary copy and checks formatting, both
linters, tests, and 100% line coverage, including the generated feature. CI runs
this check too. Raw Mustache files are excluded from analysis; their rendered Dart
is fully analyzed and tested.

## Error reporting

`ErrorReporter` is an injectable contract. `ConsoleErrorReporter` is the default
in every environment; no external reporting SDK or account is required. Supply
another implementation with `bootstrap(..., errorReporter: reporter)` to connect
a chosen service without changing features.

Flutter framework errors, root-isolate errors through `PlatformDispatcher`, and
unexpected BLoC/Cubit errors retain their original stack traces and source context.
Development also presents Flutter diagnostics and logs state changes. Handled
validation, storage, network, timeout, and HTTP-status failures remain UI state;
malformed data/responses and unexpected implementation failures are reported.
Unhandled global errors are always reported, even if their type is a domain failure.
A reporting failure is logged locally without recursively entering the reporter.
Child isolates require their own error forwarding when introduced.

## Credits and license

Architecture and implementation by [Hensell](https://github.com/Hensell).
Portfolio: [hensell.dev](https://hensell.dev).

Built from the [Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli)
Flutter starter, using Very Good Analysis, Bloc Lint, and Very Good Workflows.

Released under the [MIT License](LICENSE). You may use, modify, distribute,
and sell this software, including in commercial projects, while retaining the
copyright and license notice. The software is provided without warranty.
