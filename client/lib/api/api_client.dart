import '../models/domain.dart';
import '../models/session.dart';
import 'api_result.dart';
import 'api_transport.dart';

class ApiClient {
  const ApiClient(this._transport);

  final ApiTransport _transport;

  Future<ApiResult<Session>> login(String userName, String password) async {
    final response = await _transport.postForm('/v1/auth/login', {
      'username': userName,
      'password': password,
    });
    return _mapObject(response, Session.fromJson);
  }

  Future<ApiResult<ServerInfo>> serverInfo({String? token}) async {
    return _mapObject(
      await _transport.get('/v1/server/info', token: token),
      ServerInfo.fromJson,
    );
  }

  Future<ApiResult<List<PersonSummary>>> people(String token) async {
    return _mapList(
      await _transport.get('/v1/people', token: token),
      PersonSummary.fromJson,
    );
  }

  Future<ApiResult<PersonSummary>> person(String token, String personId) async {
    return _mapObject(
      await _transport.get('/v1/people/$personId', token: token),
      PersonSummary.fromJson,
    );
  }

  Future<ApiResult<PersonSummary>> createPerson({
    required String token,
    required String displayName,
    String? employeeCode,
    String? jobTitle,
  }) async {
    return _mapObject(
      await _transport.postJson(
          '/v1/people',
          {
            'display_name': displayName,
            if (employeeCode != null && employeeCode.isNotEmpty)
              'employee_code': employeeCode,
            if (jobTitle != null && jobTitle.isNotEmpty) 'job_title': jobTitle,
            'extra_data': <String, Object?>{},
          },
          token: token),
      PersonSummary.fromJson,
    );
  }

  Future<ApiResult<PersonSummary>> updatePerson({
    required String token,
    required String personId,
    required String displayName,
    String? employeeCode,
    String? jobTitle,
  }) async {
    return _mapObject(
      await _transport.patchJson(
        '/v1/people/$personId',
        {
          'display_name': displayName,
          'employee_code': employeeCode,
          'job_title': jobTitle,
        },
        token: token,
      ),
      PersonSummary.fromJson,
    );
  }

  Future<ApiResult<void>> deletePerson({
    required String token,
    required String personId,
  }) async {
    final response =
        await _transport.delete('/v1/people/$personId', token: token);
    if (response.isOk) return const ApiSuccess<void>(null);
    return ApiError(ApiFailure.fromStatus(response.statusCode, response.body));
  }

  Future<ApiResult<FaceTemplateSummary>> uploadEnrollmentSample({
    required String token,
    required String personId,
    required String fileName,
    required List<int> bytes,
    required String expectedPose,
  }) async {
    return _mapObject(
      await _transport.postMultipart(
        '/v1/faces/$personId/samples',
        fileField: 'file',
        fileName: fileName,
        bytes: bytes,
        fields: {'expected_pose': expectedPose},
        token: token,
      ),
      FaceTemplateSummary.fromJson,
    );
  }

  Future<ApiResult<RecognitionResult>> identify({
    required String token,
    required String fileName,
    required List<int> bytes,
  }) async {
    return _mapObject(
      await _transport.postMultipart(
        '/v1/recognitions/identify',
        fileField: 'file',
        fileName: fileName,
        bytes: bytes,
        token: token,
      ),
      RecognitionResult.fromJson,
    );
  }

  Future<ApiResult<List<RecognitionEvent>>> events(String token) async {
    return _mapList(
      await _transport.get('/v1/events', token: token),
      RecognitionEvent.fromJson,
    );
  }

  Future<ApiResult<SystemConfig>> config(String token) async {
    return _mapObject(
      await _transport.get('/v1/config', token: token),
      SystemConfig.fromJson,
    );
  }
}

ApiResult<T> _mapObject<T>(
  ApiResponse response,
  T Function(Map<String, Object?>) fromJson,
) {
  if (!response.isOk)
    return ApiError(ApiFailure.fromStatus(response.statusCode, response.body));
  final body = response.body;
  if (body is Map<String, Object?>) return ApiSuccess(fromJson(body));
  return const ApiError(
    ApiFailure(statusCode: 0, operatorMessage: 'Invalid server response.'),
  );
}

ApiResult<List<T>> _mapList<T>(
  ApiResponse response,
  T Function(Map<String, Object?>) fromJson,
) {
  if (!response.isOk)
    return ApiError(ApiFailure.fromStatus(response.statusCode, response.body));
  final body = response.body;
  if (body is List) {
    return ApiSuccess([
      for (final item in body)
        if (item is Map<String, Object?>) fromJson(item),
    ]);
  }
  return const ApiError(
    ApiFailure(statusCode: 0, operatorMessage: 'Invalid server response.'),
  );
}
