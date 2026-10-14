import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> show(WidgetTester tester, Widget child, {bool dark = false}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(body: child),
        ),
      );

  testWidgets('themes provide monochrome contrast and semantic typography', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      await show(
        tester,
        AppContent(
          children: [
            for (final variant in AppTextStyle.values)
              AppText(
                variant.name,
                variant: variant,
                semanticsLabel: 'Readable',
              ),
            const AppGap(AppSpacing.small),
            const AppDivider(),
            const AppProgress(label: 'Loading'),
          ],
        ),
        dark: dark,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('heading'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final theme = Theme.of(tester.element(find.text('heading')));
      expect(theme.colorScheme.surface, dark ? Colors.black : Colors.white);
      expect(theme.colorScheme.onSurface, dark ? Colors.white : Colors.black);
    }
  });

  testWidgets('buttons forward callbacks and respect disabled state', (
    tester,
  ) async {
    for (final variant in AppButtonStyle.values) {
      var calls = 0;
      await show(
        tester,
        AppButton(
          label: 'Action',
          icon: Icons.add,
          variant: variant,
          onPressed: () => calls++,
        ),
      );
      await tester.tap(find.text('Action'));
      expect(calls, 1);
      await show(
        tester,
        AppButton(
          label: 'Action',
          icon: Icons.add,
          variant: variant,
          onPressed: null,
        ),
      );
      await tester.tap(find.text('Action'));
      expect(calls, 1);
    }
  });

  testWidgets('screen chrome and icon controls forward actions', (
    tester,
  ) async {
    var calls = 0;
    await show(
      tester,
      AppScreen(
        title: 'Screen',
        body: const AppText('Body'),
        actions: [
          AppIconButton(
            tooltip: 'Refresh',
            icon: Icons.refresh,
            onPressed: () => calls++,
          ),
        ],
        floatingActionButton: AppFloatingAction(
          heroTag: 'action',
          icon: Icons.add,
          onPressed: () => calls++,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Refresh'));
    await tester.tap(find.byIcon(Icons.add));
    expect(calls, 2);
    expect(find.text('Screen'), findsOneWidget);
    await show(
      tester,
      const AppIconButton(
        tooltip: 'Disabled',
        icon: Icons.refresh,
        onPressed: null,
      ),
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
  });

  testWidgets('field supports controlled input and submission', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? submitted;
    await show(
      tester,
      AppTextField(
        controller: controller,
        label: 'Note',
        enabled: true,
        maxLength: 20,
        onSubmitted: (value) => submitted = value,
      ),
    );
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(controller.text, 'Hello');
    expect(submitted, 'Hello');
    await show(
      tester,
      AppTextField(
        controller: controller,
        label: 'Note',
        enabled: false,
        maxLength: 20,
        onSubmitted: (_) {},
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('radio choices support selection, icons and disabled states', (
    tester,
  ) async {
    int? selected = 1;
    await show(
      tester,
      RadioGroup<int>(
        groupValue: selected,
        onChanged: (value) => selected = value,
        child: const Column(
          children: [
            AppRadioTile(value: 1, label: 'One', enabled: true),
            AppRadioTile(
              value: 2,
              label: 'Two',
              enabled: true,
              icon: Icons.check,
            ),
            AppRadioTile(value: 3, label: 'Three', enabled: false),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Two'));
    expect(selected, 2);
    await tester.tap(find.text('Three'));
    expect(selected, 2);
  });

  testWidgets('content width, row action and divider spacing follow tokens', (
    tester,
  ) async {
    var calls = 0;
    await show(
      tester,
      AppContent(
        maxWidth: AppLayout.readingWidth,
        children: [
          AppListTile(
            title: 'Entry',
            trailing: AppIconButton(
              tooltip: 'Delete',
              icon: Icons.delete,
              onPressed: () => calls++,
            ),
          ),
          const AppListTile(title: 'Plain'),
          const AppDivider(spacing: AppSpacing.divider),
        ],
      ),
    );
    await tester.tap(find.byTooltip('Delete'));
    expect(calls, 1);
    expect(find.text('Plain'), findsOneWidget);
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.padding, const EdgeInsets.all(AppSpacing.section));
  });
}
