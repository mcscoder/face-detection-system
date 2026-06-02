import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/api_provider.dart';
import 'app.dart';

const _apiBaseUrl = String.fromEnvironment('FACE_API_BASE_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final envUrl = _apiBaseUrl.isNotEmpty ? _apiBaseUrl : await _envApiBaseUrl();
  runApp(
    FaceDetectionClientApp(
      initialApiProvider: apiProviderForUrl(envUrl),
    ),
  );
}

Future<String?> _envApiBaseUrl() async {
  try {
    final body = await rootBundle.loadString('env/mobile.json');
    final json = jsonDecode(body);
    return json is Map<String, Object?>
        ? json['FACE_API_BASE_URL'] as String?
        : null;
  } catch (_) {
    return null;
  }
}
