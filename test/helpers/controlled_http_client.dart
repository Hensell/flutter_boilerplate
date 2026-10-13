import 'dart:async';

import 'package:http/http.dart' as http;

class ControlledHttpClient extends http.BaseClient {
  final response = Completer<http.StreamedResponse>();
  http.BaseRequest? request;
  int closeCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest value) {
    request = value;
    return response.future;
  }

  @override
  void close() => closeCount++;
}
