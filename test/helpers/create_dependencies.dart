import 'package:flutter_boilerplate/app/di/app_dependencies.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'memory_local_store.dart';

Future<AppDependencies> createDependencies([
  MemoryLocalStore? store,
  http.Client? httpClient,
]) => AppDependencies.create(
  store: store ?? MemoryLocalStore(),
  httpClient: httpClient ?? MockClient((_) async => http.Response('[]', 200)),
  config: const AppConfig(environment: AppEnvironment.development),
);
