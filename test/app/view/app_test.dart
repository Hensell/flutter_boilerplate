// Ignore for testing purposes

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/app.dart';
import 'package:flutter_boilerplate/features/about/presentation/views/about_page.dart';
import 'package:flutter_boilerplate/features/counter/counter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/create_dependencies.dart';

void main() {
  group('App', () {
    testWidgets('navigates to about and preserves counter on return', (
      tester,
    ) async {
      await tester.pumpWidget(App(dependencies: await createDependencies()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.byType(AboutPage), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(CounterPage), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App(dependencies: await createDependencies()));
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
