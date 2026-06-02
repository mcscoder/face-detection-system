enum RecognitionDecision {
  allow,
  deny,
  review,
  noFace,
  multiFace,
  lowQuality,
  error,
}

class ServerInfo {
  const ServerInfo({
    required this.name,
    required this.version,
    required this.status,
    this.modelPack,
  });

  final String name;
  final String version;
  final String status;
  final String? modelPack;

  factory ServerInfo.fromJson(Map<String, Object?> json) {
    final model = json['model'];
    final modelMap = model is Map<String, Object?> ? model : const {};
    final loaded = modelMap['loaded'] == true ? 'model loaded' : 'model idle';
    return ServerInfo(
      name: json['service'] as String? ??
          json['name'] as String? ??
          'Face Detection Server',
      version: json['version'] as String? ?? 'unknown',
      status: json['status'] as String? ?? loaded,
      modelPack: modelMap['model_pack'] as String?,
    );
  }
}

class PersonSummary {
  const PersonSummary({
    required this.id,
    required this.displayName,
    this.employeeCode,
    this.jobTitle,
    this.accessStatus = 'unknown',
    this.metadata = const {},
    this.enrollmentKey,
  });

  final String id;
  final String displayName;
  final String? employeeCode;
  final String? jobTitle;
  final String accessStatus;
  final Map<String, Object?> metadata;
  final String? enrollmentKey;

  factory PersonSummary.fromJson(Map<String, Object?> json) {
    return PersonSummary(
      id: json['person_id'] as String? ?? json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ??
          json['name'] as String? ??
          'Unnamed',
      employeeCode: json['employee_code'] as String?,
      jobTitle: json['job_title'] as String?,
      accessStatus: json['access_status'] as String? ?? 'unknown',
      enrollmentKey: json['enrollment_key'] as String?,
      metadata: json['extra_data'] is Map<String, Object?>
          ? json['extra_data'] as Map<String, Object?>
          : json['metadata'] is Map<String, Object?>
              ? json['metadata'] as Map<String, Object?>
              : const {},
    );
  }
}

class FaceTemplateSummary {
  const FaceTemplateSummary({
    required this.id,
    required this.personId,
    required this.modelPack,
    required this.isActive,
    this.qualityScore,
  });

  final String id;
  final String personId;
  final String modelPack;
  final bool isActive;
  final double? qualityScore;

  factory FaceTemplateSummary.fromJson(Map<String, Object?> json) {
    return FaceTemplateSummary(
      id: json['id'] as String? ?? '',
      personId: json['person_id'] as String? ?? '',
      modelPack: json['model_pack'] as String? ?? 'unknown',
      isActive: json['is_active'] == true,
      qualityScore: _doubleValue(json['quality_score']),
    );
  }
}

class RecognitionResult {
  const RecognitionResult({
    required this.decision,
    this.personId,
    this.similarityScore,
    this.threshold,
    this.eventId,
    this.message,
  });

  final RecognitionDecision decision;
  final String? personId;
  final double? similarityScore;
  final double? threshold;
  final String? eventId;
  final String? message;

  factory RecognitionResult.fromJson(Map<String, Object?> json) {
    return RecognitionResult(
      decision: decisionFromText(
        json['failure_reason'] as String? ?? json['decision'] as String?,
      ),
      personId: json['person_id'] as String?,
      similarityScore: _doubleValue(json['similarity_score']),
      threshold: _doubleValue(json['threshold']),
      eventId: json['event_id'] as String?,
      message: json['failure_reason'] as String? ?? json['message'] as String?,
    );
  }

  static RecognitionDecision decisionFromText(String? text) {
    return switch (text?.toUpperCase()) {
      'ALLOW' || 'MATCH' => RecognitionDecision.allow,
      'DENY' || 'LOW_SCORE' => RecognitionDecision.deny,
      'REVIEW' => RecognitionDecision.review,
      'NO_FACE' => RecognitionDecision.noFace,
      'MULTI_FACE' || 'MULTIPLE_FACES' => RecognitionDecision.multiFace,
      'LOW_QUALITY' => RecognitionDecision.lowQuality,
      _ => RecognitionDecision.error,
    };
  }
}

class RecognitionEvent {
  const RecognitionEvent({
    required this.id,
    required this.decision,
    required this.createdAt,
    this.personId,
  });

  final String id;
  final RecognitionDecision decision;
  final DateTime createdAt;
  final String? personId;

  factory RecognitionEvent.fromJson(Map<String, Object?> json) {
    return RecognitionEvent(
      id: json['event_id'] as String? ?? json['id'] as String? ?? '',
      decision: RecognitionResult.decisionFromText(json['decision'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime(1970),
      personId: json['person_id'] as String?,
    );
  }
}

class SystemConfig {
  const SystemConfig({required this.threshold, required this.retentionDays});

  final double threshold;
  final int retentionDays;

  factory SystemConfig.fromJson(Map<String, Object?> json) {
    return SystemConfig(
      threshold: _doubleValue(json['recognition_threshold']) ??
          _doubleValue(json['threshold']) ??
          0.5,
      retentionDays: json['probe_retention_days'] as int? ??
          json['retention_days'] as int? ??
          30,
    );
  }
}

double? _doubleValue(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
