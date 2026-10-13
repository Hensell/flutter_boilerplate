import 'package:flutter_boilerplate/app/app.dart';
import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';

Future<void> main() async {
  await bootstrap(
    (dependencies) => App(dependencies: dependencies),
    config: const AppConfig(environment: AppEnvironment.staging),
  );
}
