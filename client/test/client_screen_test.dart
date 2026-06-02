import 'dart:async';

import 'package:face_detection_client/api/api_client.dart';
import 'package:face_detection_client/api/api_transport.dart';
import 'package:face_detection_client/screens/capture_screen.dart';
import 'package:face_detection_client/screens/enrollment_screen.dart';
import 'package:face_detection_client/screens/people_screen.dart';
import 'package:face_detection_client/screens/shell_screen.dart';
import 'package:face_detection_client/screens/user_enrollment_screen.dart';
import 'package:face_detection_client/services/enrollment_camera_session.dart';
import 'package:face_detection_client/state/app_controller.dart';
import 'package:face_detection_client/widgets/face_oval_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell opens in public user mode without login', (tester) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await tester.pumpWidget(
      MaterialApp(home: ShellScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.text('Face Detection Demo'), findsOneWidget);
    expect(find.text('Verify Face'), findsOneWidget);
    expect(find.text('Enroll Face'), findsOneWidget);
    expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    expect(find.text('Login'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);

    controller.dispose();
  });

  testWidgets('manager entry opens login and login opens manager shell', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await tester.pumpWidget(
      MaterialApp(home: ShellScreen(controller: controller)),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.admin_panel_settings));
    await tester.pump();

    expect(find.text('Manager Console'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('People'), findsWidgets);

    controller.dispose();
  });

  testWidgets('manager logout returns to public user mode', (tester) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await tester.pumpWidget(
      MaterialApp(home: ShellScreen(controller: controller)),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.admin_panel_settings));
    await tester.pump();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Verify Face'), findsOneWidget);
    expect(find.text('Enroll Face'), findsOneWidget);
    expect(find.text('Login'), findsNothing);

    controller.dispose();
  });

  testWidgets('public verify identifies without login', (tester) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptureScreen(
            controller: controller,
            cameraSession: camera,
            publicMode: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(CaptureScreen),
        matching: find.byType(ListView),
      ),
      findsNothing,
    );
    expect(find.byType(FaceOvalGuide), findsOneWidget);
    expect(find.text('Score'), findsNothing);
    expect(find.text('Threshold'), findsNothing);

    await tester.tap(find.text('Scan Face'));
    await tester.pumpAndSettle();

    expect(controller.value.isLoggedIn, isFalse);
    expect(camera.captureCount, 1);
    expect(controller.value.lastResult?.eventId, 'evt-demo');
    expect(find.text('Not verified'), findsOneWidget);
    expect(find.text('evt-demo'), findsNothing);
    expect(find.text('Threshold'), findsNothing);

    controller.dispose();
  });

  testWidgets('public verify clears stale result when opened', (tester) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();
    await controller.identifyUserImage(fileName: 'old.jpg', bytes: const [1]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptureScreen(
            controller: controller,
            cameraSession: camera,
            publicMode: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Scan Face'), findsOneWidget);
    expect(find.text('Not verified'), findsNothing);
    expect(camera.captureCount, 0);

    controller.dispose();
  });

  testWidgets('public verify route clears stale result after mount', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    await controller.identifyUserImage(fileName: 'old.jpg', bytes: const [1]);

    await tester.pumpWidget(
      MaterialApp(home: ShellScreen(controller: controller)),
    );
    await tester.pump();
    await tester.tap(
      find.ancestor(
        of: find.text('Verify Face'),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byType(CaptureScreen), findsOneWidget);
    expect(find.text('Not verified'), findsNothing);

    controller.dispose();
  });

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

  testWidgets('public user enrollment captures all guided poses without login',
      (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserEnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    expect(find.text('Step 1 of 2'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Public User');
    await tester.pump();
    await tester.tap(find.text('Start Enrollment'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.byType(FaceOvalGuide), findsOneWidget);

    for (var index = 0; index < 5; index++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    }

    expect(controller.value.isLoggedIn, isFalse);
    expect(camera.captureCount, 5);
    expect(find.text('Enrollment complete.'), findsOneWidget);
    expect(find.text('5 accepted samples. 0 more required.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('public user enrollment retry text fits a short screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 420));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _CaptureFailingCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserEnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Public User');
    await tester.pump();
    await tester.tap(find.text('Start Enrollment'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Try Again'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('public user enrollment cancel ignores pending capture', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final transport = _CountingEnrollmentUploadTransport();
    final controller = AppController(ApiClient(transport));
    final camera = _DelayedCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserEnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Public User');
    await tester.pump();
    await tester.tap(find.text('Start Enrollment'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    camera.completeCapture();
    await tester.pump();

    expect(transport.sampleUploads, 0);
    expect(find.text('Step 1 of 2'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('public user enrollment does not create person if camera fails', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final transport = _CountingCreateTransport();
    final controller = AppController(ApiClient(transport));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserEnrollmentScreen(
            controller: controller,
            cameraSession: _FailingCameraSession(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Public User');
    await tester.pump();
    await tester.tap(find.text('Start Enrollment'));
    await tester.pumpAndSettle();

    expect(transport.createCalls, 0);
    expect(find.text('Camera unavailable.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('public user enrollment cancel returns to name step', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _FakeCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserEnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Public User');
    await tester.pump();
    await tester.tap(find.text('Start Enrollment'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Step 2 of 2'), findsNothing);

    controller.dispose();
  });

  testWidgets('public user enrollment capture failure can retry same step', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    final camera = _CaptureFailingCameraSession();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserEnrollmentScreen(
            controller: controller,
            cameraSession: camera,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Public User');
    await tester.pump();
    await tester.tap(find.text('Start Enrollment'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Face forward'), findsOneWidget);
    expect(find.text('0 accepted samples. 5 more required.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('manager shell starts on people management after login', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    await controller.login('admin', 'password');

    await tester.pumpWidget(
      MaterialApp(home: ShellScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.text('Manager Console'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('People'), findsWidgets);
    expect(find.text('Sample Person'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('people tab opens detail, updates, and removes a person', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    await controller.login('admin', 'password');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PeopleScreen(controller: controller)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Sample Person'));
    await tester.pumpAndSettle();

    expect(find.text('Person Detail'), findsOneWidget);
    expect(find.text('Sample Person'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Updated Person');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Person'), findsOneWidget);
    expect(controller.value.people.first.displayName, 'Updated Person');

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(controller.value.people, isEmpty);
    expect(find.text('Updated Person'), findsNothing);

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

  testWidgets('guided enrollment wrong pose keeps the same prompt', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final transport = _WrongPoseEnrollmentTransport();
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

    await tester.enterText(find.byType(TextField).first, 'Wrong Pose Person');
    await tester.pump();
    await tester.tap(find.text('Create Person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Face Setup'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(transport.sampleUploads, 2);
    expect(transport.expectedPoses, ['face_forward', 'turn_left']);
    expect(
      find.text('Follow the current face prompt. Retrying Turn left.'),
      findsOneWidget,
    );
    expect(find.text('1 accepted samples. 4 more required.'), findsOneWidget);
    expect(find.text('Turn left'), findsOneWidget);

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
  double get previewAspectRatio => 3 / 4;

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

class _FailingCameraSession implements EnrollmentCameraSession {
  @override
  bool isReady = false;

  @override
  double get previewAspectRatio => 3 / 4;

  @override
  Future<void> initialize() async {
    throw StateError('camera failed');
  }

  @override
  Future<EnrollmentCapture> capture() async {
    throw StateError('camera failed');
  }

  @override
  Widget buildPreview() {
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> dispose() async {}
}

class _CaptureFailingCameraSession implements EnrollmentCameraSession {
  @override
  bool isReady = false;

  @override
  double get previewAspectRatio => 3 / 4;

  @override
  Future<void> initialize() async {
    isReady = true;
  }

  @override
  Future<EnrollmentCapture> capture() async {
    throw StateError('capture failed');
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

class _DelayedCameraSession implements EnrollmentCameraSession {
  Completer<EnrollmentCapture>? _capture;

  @override
  bool isReady = false;

  @override
  double get previewAspectRatio => 3 / 4;

  @override
  Future<void> initialize() async {
    isReady = true;
  }

  @override
  Future<EnrollmentCapture> capture() {
    _capture = Completer<EnrollmentCapture>();
    return _capture!.future;
  }

  void completeCapture() {
    _capture?.complete(
      const EnrollmentCapture(fileName: 'delayed.jpg', bytes: [1]),
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

class _CountingCreateTransport extends DemoApiTransport {
  int createCalls = 0;

  @override
  Future<ApiResponse> postJson(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    if (path == '/v1/user/people') createCalls++;
    return super.postJson(path, body, token: token);
  }
}

class _CountingEnrollmentUploadTransport extends DemoApiTransport {
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
    if (path.contains('/v1/user/faces/')) sampleUploads++;
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

class _WrongPoseEnrollmentTransport extends DemoApiTransport {
  int sampleUploads = 0;
  final List<String> expectedPoses = [];

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
      expectedPoses.add(fields['expected_pose'] ?? '');
      if (sampleUploads == 2) {
        return const ApiResponse(
          statusCode: 400,
          body: {'detail': 'WRONG_POSE'},
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
