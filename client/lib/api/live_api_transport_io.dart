import 'dart:convert';
import 'dart:io';

import 'api_transport.dart';

ApiTransport createPlatformLiveApiTransport(Uri baseUrl) {
  return LiveApiTransportIo(baseUrl);
}

class LiveApiTransportIo implements ApiTransport {
  LiveApiTransportIo(this.baseUrl, {HttpClient? client})
      : _client = client ?? HttpClient();

  final Uri baseUrl;
  final HttpClient _client;

  void close({bool force = false}) => _client.close(force: force);

  @override
  Future<ApiResponse> get(String path, {String? token}) async {
    try {
      final request = await _client.getUrl(_uri(path));
      _authorize(request, token);
      return _read(request);
    } catch (_) {
      return _networkError();
    }
  }

  @override
  Future<ApiResponse> postForm(
    String path,
    Map<String, String> body, {
    String? token,
  }) async {
    try {
      final request = await _client.postUrl(_uri(path));
      _authorize(request, token);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.write(Uri(queryParameters: body).query);
      return _read(request);
    } catch (_) {
      return _networkError();
    }
  }

  @override
  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    try {
      final request = await _client.postUrl(_uri(path));
      _authorize(request, token);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
      return _read(request);
    } catch (_) {
      return _networkError();
    }
  }

  @override
  Future<ApiResponse> postMultipart(
    String path, {
    required String fileField,
    required String fileName,
    required List<int> bytes,
    Map<String, String> fields = const {},
    String? token,
  }) async {
    try {
      final boundary =
          'face-detection-${DateTime.now().microsecondsSinceEpoch}';
      final request = await _client.postUrl(_uri(path));
      _authorize(request, token);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      for (final entry in fields.entries) {
        _writePartHeader(request, boundary, entry.key);
        request.write(entry.value);
        request.write('\r\n');
      }
      _writePartHeader(
        request,
        boundary,
        fileField,
        fileName: fileName,
        contentType: _fileContentType(fileName),
      );
      request.add(bytes);
      request.write('\r\n--$boundary--\r\n');
      return _read(request);
    } catch (_) {
      return _networkError();
    }
  }

  Uri _uri(String path) => baseUrl.resolve(path);

  static void _authorize(HttpClientRequest request, String? token) {
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
  }

  static void _writePartHeader(
    HttpClientRequest request,
    String boundary,
    String name, {
    String? fileName,
    String? contentType,
  }) {
    request.write('--$boundary\r\n');
    request.write('Content-Disposition: form-data; name="$name"');
    if (fileName != null) {
      request.write('; filename="${_safeFileName(fileName)}"');
    }
    request.write('\r\n');
    if (contentType != null) request.write('Content-Type: $contentType\r\n');
    request.write('\r\n');
  }

  static String _fileContentType(String fileName) {
    return fileName.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
  }

  static String _safeFileName(String fileName) {
    final parts = fileName.split(RegExp(r'[\\/]'));
    final value = parts.isEmpty ? '' : parts.last.trim();
    final buffer = StringBuffer();
    for (final codeUnit in value.codeUnits) {
      final isDigit = codeUnit >= 48 && codeUnit <= 57;
      final isUpper = codeUnit >= 65 && codeUnit <= 90;
      final isLower = codeUnit >= 97 && codeUnit <= 122;
      final isSafeSymbol = codeUnit == 45 || codeUnit == 46 || codeUnit == 95;
      buffer.write(isDigit || isUpper || isLower || isSafeSymbol
          ? String.fromCharCode(codeUnit)
          : '_');
    }
    final sanitized = buffer.toString();
    if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
      return 'upload.jpg';
    }
    return sanitized.length > 120
        ? sanitized.substring(sanitized.length - 120)
        : sanitized;
  }

  static Future<ApiResponse> _read(HttpClientRequest request) async {
    try {
      final response = await request.close();
      final text = await utf8.decoder.bind(response).join();
      return ApiResponse(
        statusCode: response.statusCode,
        body: _decodeResponse(text),
      );
    } catch (_) {
      return const ApiResponse(
        statusCode: 0,
        body: {'detail': 'NETWORK_ERROR'},
      );
    }
  }

  static ApiResponse _networkError() {
    return const ApiResponse(
      statusCode: 0,
      body: {'detail': 'NETWORK_ERROR'},
    );
  }

  static Object? _decodeResponse(String text) {
    if (text.isEmpty) return null;
    return _normalize(jsonDecode(text));
  }

  static Object? _normalize(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _normalize(entry.value),
      };
    }
    if (value is List) return [for (final item in value) _normalize(item)];
    return value;
  }
}
