class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final Object? body;

  bool get isOk => statusCode >= 200 && statusCode < 300;
}

abstract interface class ApiTransport {
  Future<ApiResponse> get(String path, {String? token});
  Future<ApiResponse> postForm(
    String path,
    Map<String, String> body, {
    String? token,
  });
  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  });
  Future<ApiResponse> patchJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  });
  Future<ApiResponse> delete(String path, {String? token});
  Future<ApiResponse> postMultipart(
    String path, {
    required String fileField,
    required String fileName,
    required List<int> bytes,
    Map<String, String> fields,
    String? token,
  });
}

class DemoApiTransport implements ApiTransport {
  const DemoApiTransport();

  @override
  Future<ApiResponse> get(String path, {String? token}) async {
    if (path == '/v1/people/p-1001') {
      return const ApiResponse(
        statusCode: 200,
        body: {
          'id': 'p-1001',
          'employee_code': 'EMP-1',
          'display_name': 'Sample Person',
          'job_title': 'Guard',
          'access_status': 'active',
          'extra_data': <String, Object?>{},
          'created_at': '2026-05-03T00:00:00',
          'updated_at': '2026-05-03T00:00:00',
        },
      );
    }
    return switch (path) {
      '/v1/server/info' => const ApiResponse(
          statusCode: 200,
          body: {
            'service': 'face-detection-system',
            'version': '0.1.0',
            'model': {
              'model_pack': 'buffalo_m',
              'loaded': false,
              'providers': <String>[],
            },
          },
        ),
      '/v1/people' => const ApiResponse(
          statusCode: 200,
          body: [
            {
              'id': 'p-1001',
              'display_name': 'Sample Person',
              'access_status': 'active',
            },
          ],
        ),
      '/v1/events' => ApiResponse(
          statusCode: 200,
          body: [
            {
              'id': 'evt-demo',
              'decision': 'DENY',
              'created_at': DateTime.now().toIso8601String(),
              'matched': false,
              'threshold': 0.62,
            },
          ],
        ),
      '/v1/config' => const ApiResponse(
          statusCode: 200,
          body: {
            'recognition_threshold': 0.62,
            'probe_retention_days': 30,
            'model_pack': 'buffalo_m',
          },
        ),
      _ => const ApiResponse(statusCode: 404, body: {'code': 'not_found'}),
    };
  }

  @override
  Future<ApiResponse> postForm(
    String path,
    Map<String, String> body, {
    String? token,
  }) async {
    return switch (path) {
      '/v1/auth/login' => const ApiResponse(
          statusCode: 200,
          body: {
            'access_token': 'demo-token',
            'display_name': 'Local Operator',
            'roles': ['admin'],
          },
        ),
      _ => const ApiResponse(statusCode: 404, body: {'detail': 'NOT_FOUND'}),
    };
  }

  @override
  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    return switch (path) {
      '/v1/people' => const ApiResponse(
          statusCode: 201,
          body: {
            'id': 'p-1002',
            'display_name': 'New Person',
            'access_status': 'active',
            'extra_data': <String, Object?>{},
          },
        ),
      _ => const ApiResponse(statusCode: 404, body: {'code': 'not_found'}),
    };
  }

  @override
  Future<ApiResponse> patchJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    if (path == '/v1/people/p-1001') {
      return ApiResponse(
        statusCode: 200,
        body: {
          'id': 'p-1001',
          'employee_code': body['employee_code'] ?? 'EMP-1',
          'display_name': body['display_name'] ?? 'Sample Person',
          'job_title': body['job_title'],
          'access_status': 'active',
          'extra_data': <String, Object?>{},
          'created_at': '2026-05-03T00:00:00',
          'updated_at': '2026-05-03T00:00:00',
        },
      );
    }
    return const ApiResponse(statusCode: 404, body: {'code': 'not_found'});
  }

  @override
  Future<ApiResponse> delete(String path, {String? token}) async {
    if (path == '/v1/people/p-1001') {
      return const ApiResponse(statusCode: 204, body: null);
    }
    return const ApiResponse(statusCode: 404, body: {'code': 'not_found'});
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
    if (path.contains('/v1/faces/')) {
      return const ApiResponse(
        statusCode: 200,
        body: {
          'id': 'template-demo',
          'person_id': 'p-1002',
          'model_pack': 'buffalo_m',
          'model_version': 'demo',
          'is_active': true,
          'quality_score': 0.87,
        },
      );
    }
    if (path == '/v1/recognitions/identify') {
      return const ApiResponse(
        statusCode: 200,
        body: {
          'matched': false,
          'decision': 'DENY',
          'similarity_score': 0.41,
          'threshold': 0.62,
          'event_id': 'evt-demo',
          'failure_reason': 'LOW_SCORE',
        },
      );
    }
    return const ApiResponse(statusCode: 404, body: {'detail': 'NOT_FOUND'});
  }
}
