enum UserRole { admin, enrollmentOperator, operator, viewer }

class Session {
  const Session({
    required this.token,
    required this.userName,
    required this.role,
  });

  final String token;
  final String userName;
  final UserRole role;

  bool get canAdmin => role == UserRole.admin;
  bool get canEnroll =>
      role == UserRole.admin || role == UserRole.enrollmentOperator;

  factory Session.fromJson(Map<String, Object?> json) {
    final roles = json['roles'];
    return Session(
      token: json['access_token'] as String? ?? '',
      userName: json['display_name'] as String? ??
          json['user_name'] as String? ??
          'Operator',
      role: _roleFromList(roles) ?? _roleFromText(json['role'] as String?),
    );
  }

  static UserRole? _roleFromList(Object? roles) {
    if (roles is! List) return null;
    if (roles.contains('admin')) return UserRole.admin;
    if (roles.contains('enrollment_operator'))
      return UserRole.enrollmentOperator;
    if (roles.contains('operator')) return UserRole.operator;
    return null;
  }

  static UserRole _roleFromText(String? text) {
    return switch (text) {
      'admin' => UserRole.admin,
      'enrollment_operator' => UserRole.enrollmentOperator,
      'viewer' => UserRole.viewer,
      _ => UserRole.operator,
    };
  }
}
