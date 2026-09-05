import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// A 1x1 transparent PNG served for every network request in tests.
final Uint8List _fakePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

/// Surface exercised by NetworkImage (dart:io path):
/// client: autoUncompress, userAgent, getUrl/openUrl, close, maxRedirects
/// request: headers.add, close
/// response: statusCode, compressionState, listen, headers, reasonPhrase
class _FakeHttpClient extends Fake implements HttpClient {
  // NetworkImage still invokes autoUncompress/userAgent/maxRedirects at
  // runtime, but the halves of a field declaration see different halves of
  // those upstream members (getter-only `userAgent`), so @override lints
  // contradictory; plain fields + targeted ignores are the clean form.
  // ignore: annotate_overrides
  bool autoUncompress = true;
  // ignore: annotate_overrides
  String? userAgent;
  int maxRedirects = 5;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _FakeRequest();

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);
}

class _FakeRequest extends Fake implements HttpClientRequest {
  final HttpHeaders _headers = _FakeHeaders();

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<HttpClientResponse> close() async => _FakeResponse();
}

class _FakeHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  String? value(String name) => null;
}

class _FakeResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _fakePng.length;

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _FakeHeaders();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> data)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_fakePng)
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// Installs the fake HTTP overrides for the current test suite: every
/// NetworkImage request resolves to a 1x1 transparent PNG instead of
/// attempting real HTTP (which returns 400 in the test binding).
void installFakeImageHttp() {
  HttpOverrides.global = _FakeHttpOverrides();
}
