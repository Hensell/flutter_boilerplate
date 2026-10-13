import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/view/app.dart';
import 'package:flutter_boilerplate/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/create_dependencies.dart';
import '../../helpers/memory_local_store.dart';

void main() {
  testWidgets('changes language and theme without losing route or counter', (
    tester,
  ) async {
    final store = MemoryLocalStore();
    await tester.pumpWidget(App(dependencies: await createDependencies(store)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro · negro'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Apariencia'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Counter'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    final restored = await createDependencies(store);
    expect(
      restored.initialSettings,
      const AppSettings(
        language: AppLanguage.english,
        appearance: AppAppearance.dark,
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(App(dependencies: restored));
    await tester.pumpAndSettle();
    expect(find.text('Counter'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Counter'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('adds, restores and deletes a note across route visits', (
    tester,
  ) async {
    await tester.pumpWidget(App(dependencies: await createDependencies()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Una idea');
    await tester.tap(find.text('Guardar nota'));
    await tester.pumpAndSettle();
    expect(find.text('Una idea'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Una idea'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Una idea'), findsNothing);
    expect(
      find.text('Todavía no hay notas. Escribe tu primera idea arriba.'),
      findsOneWidget,
    );
  });

  for (final size in [
    const Size(320, 640),
    const Size(430, 932),
    const Size(740, 360),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('settings and notes fit $size with large text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(App(dependencies: await createDependencies()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notes_outlined));
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
