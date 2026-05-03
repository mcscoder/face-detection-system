import 'dart:convert';
import 'dart:io';

import 'package:face_detection_client/api/api_client.dart';
import 'package:face_detection_client/api/api_result.dart';
import 'package:face_detection_client/api/live_api_transport_io.dart';
import 'package:face_detection_client/models/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('live transport sends login form and bearer token', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen(_handleRequest);
    final transport = LiveApiTransportIo(
      Uri.parse('http://${server.address.host}:${server.port}'),
    );
    addTearDown(() async {
      transport.close(force: true);
      await subscription.cancel();
      await server.close(force: true);
    });

    final client = ApiClient(transport);

    final login = await client.login('admin', 'secret');
    final info = await client.serverInfo(token: 'token-1');
    final person = await client.createPerson(
      token: 'token-1',
      displayName: 'New Person',
    );
    final detail = await client.person('token-1', 'person-1');
    final updated = await client.updatePerson(
      token: 'token-1',
      personId: 'person-1',
      displayName: 'Updated Person',
      employeeCode: 'EMP-2',
      jobTitle: 'Supervisor',
    );
    final removed = await client.deletePerson(
      token: 'token-1',
      personId: 'person-1',
    );
    final template = await client.uploadEnrollmentSample(
      token: 'token-1',
      personId: 'person-1',
      fileName: 'folder/unsafe sample.jpg',
      bytes: const [1, 2, 3],
      expectedPose: 'face_forward',
    );
    final identify = await client.identify(
      token: 'token-1',
      fileName: 'probe.jpg',
      bytes: const [4, 5, 6],
    );

    expect(login, isA<ApiSuccess<Session>>());
    expect((login as ApiSuccess<Session>).value.token, 'token-1');
    expect(info, isA<ApiSuccess>());
    expect(person, isA<ApiSuccess>());
    expect(detail, isA<ApiSuccess>());
    expect(updated, isA<ApiSuccess>());
    expect(removed, isA<ApiSuccess<void>>());
    expect(template, isA<ApiSuccess>());
    expect(identify, isA<ApiSuccess>());
  });
}

Future<void> _handleRequest(HttpRequest request) async {
  if (request.uri.path == '/v1/auth/login') {
    final body = await utf8.decoder.bind(request).join();
    expect(request.headers.contentType?.mimeType,
        'application/x-www-form-urlencoded');
    expect(body, 'username=admin&password=secret');
    _writeJson(request.response, {
      'access_token': 'token-1',
      'display_name': 'Local Admin',
      'roles': ['admin'],
    });
    return;
  }

  if (request.uri.path == '/v1/server/info') {
    expect(request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer token-1');
    _writeJson(request.response, {
      'service': 'face-detection-system',
      'version': '0.1.0',
      'model': {
        'model_pack': 'buffalo_m',
        'loaded': false,
        'providers': <String>[],
      },
    });
    return;
  }

  if (request.uri.path == '/v1/people') {
    final body = jsonDecode(await utf8.decoder.bind(request).join())
        as Map<String, Object?>;
    expect(request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer token-1');
    expect(body['display_name'], 'New Person');
    _writeJson(request.response, {
      'id': 'person-1',
      'display_name': 'New Person',
      'access_status': 'active',
      'extra_data': <String, Object?>{},
      'created_at': '2026-05-03T00:00:00',
      'updated_at': '2026-05-03T00:00:00',
    });
    return;
  }

  if (request.uri.path == '/v1/people/person-1') {
    expect(request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer token-1');
    if (request.method == 'GET') {
      _writeJson(request.response, {
        'id': 'person-1',
        'employee_code': 'EMP-1',
        'display_name': 'New Person',
        'job_title': 'Guard',
        'access_status': 'active',
        'extra_data': <String, Object?>{},
        'created_at': '2026-05-03T00:00:00',
        'updated_at': '2026-05-03T00:00:00',
      });
      return;
    }
    if (request.method == 'PATCH') {
      final body = jsonDecode(await utf8.decoder.bind(request).join())
          as Map<String, Object?>;
      expect(body['display_name'], 'Updated Person');
      expect(body['employee_code'], 'EMP-2');
      _writeJson(request.response, {
        'id': 'person-1',
        'employee_code': 'EMP-2',
        'display_name': 'Updated Person',
        'job_title': 'Supervisor',
        'access_status': 'active',
        'extra_data': <String, Object?>{},
        'created_at': '2026-05-03T00:00:00',
        'updated_at': '2026-05-03T00:00:00',
      });
      return;
    }
    if (request.method == 'DELETE') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }
  }

  if (request.uri.path == '/v1/faces/person-1/samples') {
    await _expectMultipart(
      request,
      fileName: 'unsafe_sample.jpg',
      expectedBytes: const [1, 2, 3],
      expectedFields: const {'expected_pose': 'face_forward'},
    );
    _writeJson(request.response, {
      'id': 'template-1',
      'person_id': 'person-1',
      'model_pack': 'buffalo_m',
      'model_version': '0.0',
      'is_active': true,
      'quality_score': 0.82,
    });
    return;
  }

  if (request.uri.path == '/v1/recognitions/identify') {
    await _expectMultipart(
      request,
      fileName: 'probe.jpg',
      expectedBytes: const [4, 5, 6],
    );
    _writeJson(request.response, {
      'event_id': 'event-1',
      'matched': false,
      'decision': 'DENY',
      'threshold': 0.62,
      'failure_reason': 'LOW_SCORE',
    });
    return;
  }

  request.response.statusCode = HttpStatus.notFound;
  await request.response.close();
}

Future<void> _expectMultipart(
  HttpRequest request, {
  required String fileName,
  required List<int> expectedBytes,
  Map<String, String> expectedFields = const {},
}) async {
  final contentType = request.headers.contentType;
  final body = await request.fold<List<int>>(
    <int>[],
    (buffer, chunk) => buffer..addAll(chunk),
  );
  final text = utf8.decode(body, allowMalformed: true);
  expect(
      request.headers.value(HttpHeaders.authorizationHeader), 'Bearer token-1');
  expect(contentType?.mimeType, 'multipart/form-data');
  expect(contentType?.parameters['boundary'], isNotEmpty);
  expect(text, contains('name="file"'));
  expect(text, contains('filename="$fileName"'));
  for (final entry in expectedFields.entries) {
    expect(text, contains('name="${entry.key}"'));
    expect(text, contains(entry.value));
  }
  expect(_containsBytes(body, expectedBytes), isTrue);
}

bool _containsBytes(List<int> body, List<int> expected) {
  for (var index = 0; index <= body.length - expected.length; index++) {
    var matches = true;
    for (var offset = 0; offset < expected.length; offset++) {
      if (body[index + offset] != expected[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}

void _writeJson(HttpResponse response, Map<String, Object?> body) {
  response.headers.set(HttpHeaders.connectionHeader, 'close');
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  response.close();
}
