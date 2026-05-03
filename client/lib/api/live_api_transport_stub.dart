import 'api_transport.dart';

ApiTransport createPlatformLiveApiTransport(Uri baseUrl) {
  return const _UnsupportedLiveApiTransport();
}

class _UnsupportedLiveApiTransport implements ApiTransport {
  const _UnsupportedLiveApiTransport();

  @override
  Future<ApiResponse> get(String path, {String? token}) async {
    return _networkError();
  }

  @override
  Future<ApiResponse> postForm(
    String path,
    Map<String, String> body, {
    String? token,
  }) async {
    return _networkError();
  }

  @override
  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    return _networkError();
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
    return _networkError();
  }
}

ApiResponse _networkError() {
  return const ApiResponse(
    statusCode: 0,
    body: {'detail': 'NETWORK_ERROR'},
  );
}
