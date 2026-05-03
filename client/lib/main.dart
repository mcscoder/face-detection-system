import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/api_transport.dart';
import 'api/live_api_transport.dart';
import 'app.dart';

const _apiBaseUrl = String.fromEnvironment('FACE_API_BASE_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FaceDetectionClientApp(transport: await _transport()));
}

Future<ApiTransport> _transport() async {
  final envUrl = _apiBaseUrl.isNotEmpty ? _apiBaseUrl : await _envApiBaseUrl();
  if (envUrl == null || envUrl.isEmpty) return const DemoApiTransport();
  return createLiveApiTransport(Uri.parse(envUrl));
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
