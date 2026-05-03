import 'package:face_detection_client/api/api_client.dart';
import 'package:face_detection_client/api/api_transport.dart';
import 'package:face_detection_client/screens/capture_screen.dart';
import 'package:face_detection_client/screens/enrollment_screen.dart';
import 'package:face_detection_client/services/enrollment_camera_session.dart';
import 'package:face_detection_client/state/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture screen exposes live camera identify action', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptureScreen(controller: controller, cameraSession: camera),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Check Face'), findsOneWidget);
    expect(find.text('Gallery'), findsNothing);
    expect(find.text('Camera ready.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('capture screen identifies from live camera capture', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();
    await controller.login('admin', 'password');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptureScreen(controller: controller, cameraSession: camera),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Check Face'));
    await tester.pumpAndSettle();

    expect(camera.captureCount, 1);
    expect(controller.value.lastResult?.eventId, 'evt-demo');
    expect(find.text('Denied'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('enrollment screen exposes guided camera enrollment', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    await controller.login('admin', 'password');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EnrollmentScreen(controller: controller)),
      ),
    );

    expect(find.text('Enrollment'), findsOneWidget);
    expect(find.text('Create Person'), findsOneWidget);
    expect(find.text('Person ID'), findsOneWidget);
    expect(find.text('Start Face Setup'), findsOneWidget);
    expect(find.text('Face forward'), findsOneWidget);
    expect(find.text('Gallery'), findsNothing);
    expect(find.text('0 accepted samples. 5 more required.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('guided enrollment auto captures prompts until complete', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();
    await controller.login('admin', 'password');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'New Person');
    await tester.pump();
    await tester.tap(find.text('Create Person'));
    await tester.pumpAndSettle();
    expect(find.text('Camera ready.'), findsOneWidget);
    await tester.tap(find.text('Start Face Setup'));
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    for (var index = 0; index < 5; index++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    }

    expect(camera.captureCount, 5);
    expect(find.text('Enrollment ready for identify.'), findsOneWidget);
    expect(find.text('5 accepted samples. 0 more required.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('guided enrollment retries a rejected sample in same camera flow',
      (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final transport = _RetryEnrollmentTransport();
    final controller = AppController(ApiClient(transport));
    final camera = _FakeCameraSession();
    await controller.login('admin', 'password');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Retry Person');
    await tester.pump();
    await tester.tap(find.text('Create Person'));
    await tester.pumpAndSettle();
    expect(find.text('Camera ready.'), findsOneWidget);
    await tester.tap(find.text('Start Face Setup'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(
      find.text('No face detected. Retrying Face forward.'),
      findsOneWidget,
    );
    expect(transport.sampleUploads, 1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(transport.sampleUploads, 2);
    expect(find.text('1 accepted samples. 4 more required.'), findsOneWidget);

    controller.dispose();
  });
}

Future<void> _setLargeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

class _FakeCameraSession implements EnrollmentCameraSession {
  int captureCount = 0;

  @override
  bool isReady = false;

  @override
  Future<void> initialize() async {
    isReady = true;
  }

  @override
  Future<EnrollmentCapture> capture() async {
    captureCount++;
    return EnrollmentCapture(
      fileName: 'sample-$captureCount.jpg',
      bytes: [captureCount],
    );
  }

  @override
  Widget buildPreview() {
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> dispose() async {
    isReady = false;
  }
}

class _RetryEnrollmentTransport extends DemoApiTransport {
  int sampleUploads = 0;

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
      sampleUploads++;
      expect(fields['expected_pose'], isNotEmpty);
      if (sampleUploads == 1) {
        return const ApiResponse(
          statusCode: 400,
          body: {'detail': 'NO_FACE'},
        );
      }
    }
    return super.postMultipart(
      path,
      fileField: fileField,
      fileName: fileName,
      bytes: bytes,
      fields: fields,
      token: token,
    );
  }
}
