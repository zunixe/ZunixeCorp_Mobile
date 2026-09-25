import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// PNG 1x1 transparan.
final Uint8List kTransparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

/// `HttpOverrides` yang menjawab semua request GET dengan PNG 1x1,
/// agar `Image.network` di widget test tidak menyentuh jaringan.
class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String? realm)? f) {}

  @override
  set authenticateProxy(
      Future<bool> Function(
              String host, int port, String scheme, String? realm)?
          f) {}

  @override
  set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port)? callback) {}

  @override
  void close({bool force = false}) {}

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String? proxyHost, int? proxyPort)?
          f) {}

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      throw UnimplementedError();

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> headUrl(Uri url) => throw UnimplementedError();

  @override
  set keyLog(Function(String line)? callback) {}

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => throw UnimplementedError();

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> postUrl(Uri url) => throw UnimplementedError();

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      throw UnimplementedError();

  @override
  Future<HttpClientRequest> putUrl(Uri url) => throw UnimplementedError();
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  bool bufferOutput = true;
  @override
  int contentLength = 0;
  @override
  Encoding encoding = utf8;
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {}

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<HttpClientResponse> get done => close();

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  String get method => 'GET';

  @override
  Uri get uri => Uri.parse('https://example.com/x.png');

  @override
  Future<void> flush() async {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final Stream<List<int>> _stream =
      Stream<List<int>>.value(kTransparentPng);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  X509Certificate? get certificate => null;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  int get contentLength => kTransparentPng.length;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<Socket> detachSocket() => throw UnimplementedError();

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) =>
      throw UnimplementedError();

  @override
  List<RedirectInfo> get redirects => [];

  @override
  bool get persistentConnection => true;
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
