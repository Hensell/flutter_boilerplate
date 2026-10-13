import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/view/app.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/create_dependencies.dart';
import '../../helpers/memory_local_store.dart';

class _ControlledStore extends MemoryLocalStore {
  Completer<void>? pendingWrite;

  @override
  Future<void> write(String key, String value) async {
    final pending = pendingWrite;
    if (pending != null) await pending.future;
    await super.write(key, value);
  }
}

void main() {
  testWidgets('notes can recover from a failed initial read', (tester) async {
    final store = MemoryLocalStore();
    final dependencies = await createDependencies(store);
    store.failReads = true;
    await tester.pumpWidget(App(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo acceder al almacenamiento. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.text('Reintentar'), findsOneWidget);
    store.failReads = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo acceder al almacenamiento. Inténtalo de nuevo.'),
      findsNothing,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  testWidgets('corrupt notes display an error without destroying stored data', (
    tester,
  ) async {
    final store = MemoryLocalStore();
    store.values['notes.v1'] = '{broken';
    await tester.pumpWidget(App(dependencies: await createDependencies(store)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    expect(
      find.text('Las notas guardadas no se pueden leer. No se han modificado.'),
      findsOneWidget,
    );
    expect(store.values['notes.v1'], '{broken');
  });

  testWidgets('keyboard submission validates input and retains failed drafts', (
    tester,
  ) async {
    final store = MemoryLocalStore();
    await tester.pumpWidget(App(dependencies: await createDependencies(store)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      find.text('Escribe una nota de entre 1 y 280 caracteres.'),
      findsOneWidget,
    );
    expect(store.values.containsKey('notes.v1'), isFalse);
    store.failWrites = true;
    await tester.enterText(find.byType(TextField), 'Mi borrador');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo acceder al almacenamiento. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Mi borrador',
    );
    store.failWrites = false;
    await tester.tap(find.text('Guardar nota'));
    await tester.pumpAndSettle();
    expect(find.text('Mi borrador'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets(
    'settings disable changes while saving and retain values on failure',
    (tester) async {
      final store = _ControlledStore();
      await tester.pumpWidget(
        App(dependencies: await createDependencies(store)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      store
        ..pendingWrite = Completer<void>()
        ..failWrites = true;
      await tester.tap(find.text('Oscuro · negro'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<RadioListTile<AppLanguage>>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is RadioListTile<AppLanguage> &&
                    widget.value == AppLanguage.english,
              ),
            )
            .enabled,
        isFalse,
      );
      store.pendingWrite!.complete();
      await tester.pumpAndSettle();
      expect(
        find.text('No se pudo acceder al almacenamiento. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(
        Theme.of(tester.element(find.text('Configuración'))).brightness,
        Brightness.light,
      );
      store
        ..pendingWrite = null
        ..failWrites = false;
      await tester.tap(find.text('Oscuro · negro'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Configuración'))).brightness,
        Brightness.dark,
      );
      expect(
        find.text('No se pudo acceder al almacenamiento. Inténtalo de nuevo.'),
        findsNothing,
      );
    },
  );
}
