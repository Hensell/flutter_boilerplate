import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{package_name}}/core/errors/app_failure.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/data/datasources/{{name.snakeCase()}}_data_source.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/data/models/{{name.snakeCase()}}_item_model.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/data/repositories/{{name.snakeCase()}}_repository_impl.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_item.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/domain/repositories/{{name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/presentation/cubit/{{name.snakeCase()}}_cubit.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/presentation/cubit/{{name.snakeCase()}}_state.dart';
import 'package:{{package_name}}/features/{{name.snakeCase()}}/presentation/views/{{name.snakeCase()}}_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockRepository extends Mock implements {{name.pascalCase()}}Repository;

void main() {
  const item = {{name.pascalCase()}}Item(id: 'one', label: 'Example item');

  test('repository maps source data to immutable domain items', () async {
    const repository = {{name.pascalCase()}}RepositoryImpl({{name.pascalCase()}}DataSource(
      items: [{{name.pascalCase()}}ItemModel(id: 'one', label: 'Example item')],
    ));
    expect(await repository.fetchItems(), [item]);
  });

  test('cubit retains items on failure and does not emit after closure', () async {
    final repository = _MockRepository();
    when(repository.fetchItems).thenAnswer((_) async => [item]);
    final cubit = {{name.pascalCase()}}Cubit(repository);
    await cubit.load();
    expect(cubit.state, const {{name.pascalCase()}}State(items: [item]));
    when(repository.fetchItems).thenThrow(const AppFailure(FailureKind.network));
    await cubit.load();
    expect(cubit.state, const {{name.pascalCase()}}State(items: [item], failure: FailureKind.network));
    final pending = Completer<List<{{name.pascalCase()}}Item>>();
    when(repository.fetchItems).thenAnswer((_) => pending.future);
    final loading = cubit.load();
    await cubit.load();
    await cubit.close();
    pending.complete([]);
    await loading;
    expect(cubit.isClosed, isTrue);
  });

  testWidgets('page shows loading, data, errors, retry, and empty states', (tester) async {
    final repository = _MockRepository();
    final pending = Completer<List<{{name.pascalCase()}}Item>>();
    when(repository.fetchItems).thenAnswer((_) => pending.future);
    await tester.pumpApp(RepositoryProvider<{{name.pascalCase()}}Repository>.value(
      value: repository, child: const {{name.pascalCase()}}Page(),
    ));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    pending.complete([item]);
    await tester.pumpAndSettle();
    expect(find.text('Example item'), findsOneWidget);
    when(repository.fetchItems).thenThrow(const AppFailure(FailureKind.network));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Could not connect. Check your connection and try again.'), findsOneWidget);
    when(repository.fetchItems).thenAnswer((_) async => []);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });
}
