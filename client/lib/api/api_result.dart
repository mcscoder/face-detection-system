sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T value) ok,
    required R Function(ApiFailure failure) error,
  }) {
    return switch (this) {
      ApiSuccess<T>(value: final value) => ok(value),
      ApiError<T>(failure: final failure) => error(failure),
    };
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.value);

  final T value;
}

class ApiError<T> extends ApiResult<T> {
  const ApiError(this.failure);

  final ApiFailure failure;
}

class ApiFailure {
  const ApiFailure({
    required this.statusCode,
    required this.operatorMessage,
    this.code,
  });

  final int statusCode;
  final String operatorMessage;
  final String? code;

  factory ApiFailure.fromStatus(int statusCode, Object? body) {
    final code = _codeFromBody(body);
    return ApiFailure(
      statusCode: statusCode,
      code: code,
      operatorMessage: _messageFor(statusCode, code),
    );
  }

  static String _messageFor(int statusCode, String? code) {
    if (statusCode == 0) return 'Server unavailable.';
    if (statusCode == 401) return 'Session expired. Login again.';
    if (statusCode == 403) return 'Not allowed for this role.';
    if (statusCode == 404) return 'Record not found.';
    if (statusCode == 413) return 'Image is too large.';
    if (statusCode >= 500) return 'Server unavailable.';
    return switch (code) {
      'no_face' => 'No face detected.',
      'NO_FACE' => 'No face detected.',
      'multi_face' || 'MULTIPLE_FACES' => 'More than one face detected.',
      'low_quality' || 'LOW_QUALITY' => 'Image quality is too low.',
      'low_score' || 'LOW_SCORE' => 'Similarity score is below threshold.',
      'WRONG_POSE' => 'Follow the current face prompt.',
      'INVALID_PROMPT' => 'Face prompt is invalid.',
      'INVALID_IMAGE' => 'Image file is invalid.',
      _ => 'Request failed.',
    };
  }
}

String? _codeFromBody(Object? body) {
  if (body is! Map<String, Object?>) return null;
  final code = body['code'] ?? body['detail'];
  return code is String ? code : null;
}
