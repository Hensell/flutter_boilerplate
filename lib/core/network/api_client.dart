import 'dart:async';
import 'dart:convert';

import 'package:flutter_boilerplate/core/errors/app_failure.dart';
import 'package:http/http.dart' as http;

/// Owns an HTTP client and maps transport failures into domain failures.
class ApiClient {
  // Dart 3.13 exposes this._client as the public named argument `client`.
  /// Creates a client with an explicit endpoint and full-response deadline.
  new({required this._client, required Uri baseUri, required Duration timeout})
    : _timeout = timeout,
      _baseUri = baseUri.path.endsWith('/')
          ? baseUri
          : baseUri.replace(path: '${baseUri.path}/') {
    if (!['http', 'https'].contains(baseUri.scheme) ||
        baseUri.host.isEmpty ||
        timeout <= Duration.zero) {
      throw ArgumentError(
        'An HTTP endpoint and a positive timeout are required.',
      );
    }
  }

  final http.Client _client;
  final Uri _baseUri;
  final Duration _timeout;
  bool _isClosed = false;

  /// Reads JSON and aborts supported clients when the deadline expires.
  Future<Object?> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    if (_isClosed) throw StateError('The API client has been closed.');
    final endpoint = Uri.parse(path);
    final pathOnly = path.split('?').first.split('#').first;
    final hasTraversal = Uri.decodeComponent(pathOnly)
        .split('/')
        .contains('..');
    if (endpoint.hasScheme ||
        endpoint.hasAuthority ||
        path.startsWith('/') ||
        hasTraversal) {
      throw ArgumentError.value(
        path,
        'path',
        'Use an endpoint within the API base path.',
      );
    }
    final uri = _baseUri
        .resolve(path)
        .replace(queryParameters: queryParameters);
    final abort = Completer<void>();
    final request = http.AbortableRequest(
      'GET',
      uri,
      abortTrigger: abort.future,
    )..headers['Accept'] = 'application/json';
    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppFailure(FailureKind.server);
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException catch (error) {
      abort.complete();
      throw AppFailure(FailureKind.timeout, cause: error);
    } on http.ClientException catch (error) {
      throw AppFailure(FailureKind.network, cause: error);
    } on FormatException catch (error) {
      throw AppFailure(FailureKind.invalidResponse, cause: error);
    }
  }

  /// Releases connections, including those of an injected client, once.
  void close() {
    if (_isClosed) return;
    _isClosed = true;
    _client.close();
  }
}
