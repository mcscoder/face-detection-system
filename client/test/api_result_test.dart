import 'package:face_detection_client/api/api_client.dart';
import 'package:face_detection_client/api/api_result.dart';
import 'package:face_detection_client/api/api_transport.dart';
import 'package:face_detection_client/models/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps status codes to operator-safe errors', () async {
    final client = ApiClient(
      _FailingTransport(
        const ApiResponse(statusCode: 413, body: {'code': 'payload_too_large'}),
      ),
    );

    final result = await client.identify(
      token: 'token',
      fileName: 'large.jpg',
      bytes: const [1],
    );

    expect(result, isA<ApiError<RecognitionResult>>());
    expect(
      (result as ApiError<RecognitionResult>).failure.operatorMessage,
      'Image is too large.',
    );
  });

  test('maps recognition decisions from server text', () async {
    final client = ApiClient(_IdentifyTransport());

    final result = await client.identify(
      token: 'token',
      fileName: 'probe.jpg',
      bytes: const [1, 2],
    );

    expect(result, isA<ApiSuccess<RecognitionResult>>());
    final recognition = (result as ApiSuccess<RecognitionResult>).value;
    expect(recognition.decision, RecognitionDecision.noFace);
    expect(recognition.eventId, 'evt-1');
  });
}

class _FailingTransport implements ApiTransport {
  const _FailingTransport(this.response);

  final ApiResponse response;

  @override
  Future<ApiResponse> get(String path, {String? token}) async => response;

  @override
  Future<ApiResponse> postForm(
    String path,
    Map<String, String> body, {
    String? token,
  }) async {
    return response;
  }

  @override
  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    return response;
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
    return response;
  }
}

class _IdentifyTransport extends _FailingTransport {
  _IdentifyTransport() : super(const ApiResponse(statusCode: 200, body: {}));

  @override
  Future<ApiResponse> postMultipart(
    String path, {
    required String fileField,
    required String fileName,
    required List<int> bytes,
    Map<String, String> fields = const {},
    String? token,
  }) async {
    return const ApiResponse(
      statusCode: 200,
      body: {
        'decision': 'DENY',
        'failure_reason': 'NO_FACE',
        'event_id': 'evt-1',
        'threshold': 0.6,
      },
    );
  }
}
