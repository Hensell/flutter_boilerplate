import 'dart:async';
import 'dart:convert';

import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:flutter_boilerplate/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/controlled_http_client.dart';

void main() {
  ApiClient clientFor(
    http.Client client, {
    String endpoint = 'https://example.com/api',
    Duration timeout = const Duration(seconds: 1),
  }) =>
      ApiClient(client: client, baseUri: Uri.parse(endpoint), timeout: timeout);

  test('preserves the API prefix, query and UTF-8 response text', () async {
    final client = clientFor(
      MockClient((request) async {
        expect(request.url.toString(), 'https://example.com/api/posts?limit=2');
        expect(request.headers['Accept'], 'application/json');
        return http.Response.bytes(utf8.encode('{"title":"Café"}'), 200);
      }),
    );
    addTearDown(client.close);
    expect(await client.getJson('posts', queryParameters: {'limit': '2'}), {
      'title': 'Café',
    });
  });

  for (final code in [199, 400, 500]) {
    test('HTTP $code is a typed server failure', () async {
      final client = clientFor(
        MockClient((_) async => http.Response('{}', code)),
        endpoint: 'https://example.com/api/',
      );
      addTearDown(client.close);
      await expectLater(
        client.getJson('posts'),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            FailureKind.server,
          ),
        ),
      );
    });
  }

  test('network exceptions retain their original diagnostic cause', () async {
    final cause = http.ClientException('offline');
    final client = clientFor(MockClient((_) async => throw cause));
    addTearDown(client.close);
    await expectLater(
      client.getJson('posts'),
      throwsA(
        isA<AppFailure>()
            .having((failure) => failure.kind, 'kind', FailureKind.network)
            .having((failure) => failure.cause, 'cause', same(cause)),
      ),
    );
  });

  test('malformed JSON produces a typed response failure', () async {
    final client = clientFor(
      MockClient((_) async => http.Response('{bad', 200)),
    );
    addTearDown(client.close);
    await expectLater(
      client.getJson('posts'),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          FailureKind.invalidResponse,
        ),
      ),
    );
  });

  test(
    'deadline includes the response body and triggers request abortion',
    () async {
      final transport = ControlledHttpClient();
      final client = clientFor(
        transport,
        timeout: const Duration(milliseconds: 10),
      );
      addTearDown(client.close);
      final body = StreamController<List<int>>();
      addTearDown(body.close);
      final request = client.getJson('posts');
      transport.response.complete(http.StreamedResponse(body.stream, 200));
      await expectLater(
        request,
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            FailureKind.timeout,
          ),
        ),
      );
      final aborted = transport.request! as http.AbortableRequest;
      await expectLater(aborted.abortTrigger, completes);
    },
  );

  test(
    'invalid configuration and absolute endpoints fail before sending',
    () async {
      final transport = ControlledHttpClient();
      expect(
        () => clientFor(transport, endpoint: 'file:///data'),
        throwsArgumentError,
      );
      expect(
        () => clientFor(transport, timeout: Duration.zero),
        throwsArgumentError,
      );
      final client = clientFor(transport);
      addTearDown(client.close);
      for (final path in [
        '/posts',
        'https://other.example/posts',
        '//other.example',
        '../posts',
        '../../posts',
        '%2e%2e/posts',
        'posts/../health',
      ]) {
        await expectLater(client.getJson(path), throwsArgumentError);
      }
      expect(transport.request, isNull);
    },
  );

  test(
    'closing releases the owned transport once and refuses new requests',
    () async {
      final transport = ControlledHttpClient();
      final client = clientFor(transport)
        ..close()
        ..close();
      expect(transport.closeCount, 1);
      await expectLater(client.getJson('posts'), throwsStateError);
    },
  );
}
