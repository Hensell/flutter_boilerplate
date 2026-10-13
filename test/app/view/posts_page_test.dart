import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app/view/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/controlled_http_client.dart';
import '../../helpers/create_dependencies.dart';

void main() {
  testWidgets('remote route loads, refreshes and shows the empty state', (
    tester,
  ) async {
    var requests = 0;
    final client = MockClient(
      (_) async => http.Response(
        ++requests == 1
            ? '[{"id":1,"title":"A publication","body":"Remote content"}]'
            : '[]',
        200,
      ),
    );
    await tester.pumpWidget(
      App(dependencies: await createDependencies(null, client)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicaciones'));
    await tester.pumpAndSettle();
    expect(find.text('A publication'), findsOneWidget);
    expect(find.text('Remote content'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('No hay publicaciones disponibles.'), findsOneWidget);
    expect(requests, 2);
  });

  testWidgets('network errors are localized and retry reloads the route', (
    tester,
  ) async {
    var offline = true;
    final client = MockClient((_) async {
      if (offline) throw http.ClientException('offline');
      return http.Response('[]', 200);
    });
    await tester.pumpWidget(
      App(dependencies: await createDependencies(null, client)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicaciones'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
    offline = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('No hay publicaciones disponibles.'), findsOneWidget);
  });

  testWidgets('loading has accessible feedback and prevents another refresh', (
    tester,
  ) async {
    final client = ControlledHttpClient();
    await tester.pumpWidget(
      App(dependencies: await createDependencies(null, client)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicaciones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh))
          .onPressed,
      isNull,
    );
    client.response.complete(
      http.StreamedResponse(Stream.value('[ ]'.codeUnits), 200),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(client.closeCount, 1);
  });
}
