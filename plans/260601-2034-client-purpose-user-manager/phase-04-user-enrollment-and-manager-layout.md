# Phase 04 User Enrollment And Manager Layout

## Context Links

- Guided prompt contract: `client/lib/models/guided_enrollment.dart`
- Existing manager enrollment: `client/lib/screens/enrollment_screen.dart`
- Enrollment camera widgets: `client/lib/widgets/enrollment_camera_stage.dart`, `client/lib/widgets/enrollment_action_panel.dart`
- Manager shell: `client/lib/screens/shell_screen.dart`

## Overview

- Priority: high
- Current status: planned
- Add simple public enrollment and reorder manager navigation around user management.

## Key Insights

- Public enrollment should not expose Person ID.
- Public enrollment must still use all five guided prompts and send `expected_pose`.
- Manager can be more complex but should still be organized and smooth.

## Requirements

- Public user enrollment asks only for display name, then captures five prompts.
- Public user enrollment calls `createUserPerson` and `uploadUserEnrollmentSample`.
- Enrollment action button can use a user-facing label without breaking manager tests.
- Manager navigation starts on People and includes People, Enroll, Verify, Events, Settings.

## Architecture

`UserEnrollmentScreen` is a dedicated public flow that reuses `GuidedEnrollmentProgress`, `EnrollmentCameraStage`, `EnrollmentActionPanel`, and `EnrollmentCameraSession`. Manager screens stay existing screens behind login, with navigation order changed to emphasize user management.

## Related Code Files

- Create: `client/lib/screens/user_enrollment_screen.dart`
- Modify: `client/lib/widgets/enrollment_action_panel.dart`
- Modify: `client/lib/screens/shell_screen.dart`
- Test: `client/test/client_screen_test.dart`

## Implementation Steps

- [ ] **Step 1: Write public enrollment and manager navigation tests**

Append to `client/test/client_screen_test.dart`:

```dart
  testWidgets('public user enrollment captures all guided poses without login', (
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

    for (var index = 0; index < 5; index++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    }

    expect(controller.value.isLoggedIn, isFalse);
    expect(camera.captureCount, 5);
    expect(find.text('Enrollment complete.'), findsOneWidget);
    expect(find.text('5 accepted samples. 0 more required.'), findsOneWidget);
  });

  testWidgets('manager shell starts on people management after login', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));
    await controller.login('admin', 'password');

    await tester.pumpWidget(MaterialApp(home: ShellScreen(controller: controller)));
    await tester.pump();

    expect(find.text('Manager'), findsOneWidget);
    expect(find.text('People'), findsWidgets);
    expect(find.text('Sample Person'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    controller.dispose();
  });
```

Add this import to `client/test/client_screen_test.dart`:

```dart
import 'package:face_detection_client/screens/user_enrollment_screen.dart';
```

- [ ] **Step 2: Run screen tests to verify they fail**

Run from `client/`:

```bash
flutter test test/client_screen_test.dart
```

Expected: FAIL because `UserEnrollmentScreen` does not exist.

- [ ] **Step 3: Allow enrollment action label override**

Modify `client/lib/widgets/enrollment_action_panel.dart`.

Change constructor and add field:

```dart
  const EnrollmentActionPanel({
    super.key,
    required this.progress,
    required this.canStart,
    required this.isActive,
    required this.onStart,
    required this.onCancel,
    this.startLabel = 'Start Face Setup',
  });

  final GuidedEnrollmentProgress progress;
  final bool canStart;
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final String startLabel;
```

Replace button label:

```dart
                label: Text(startLabel),
```

- [ ] **Step 4: Create public user enrollment screen**

Create `client/lib/screens/user_enrollment_screen.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guided_enrollment.dart';
import '../services/enrollment_camera_session.dart';
import '../state/app_controller.dart';
import '../widgets/enrollment_action_panel.dart';
import '../widgets/enrollment_camera_stage.dart';
import '../widgets/status_banner.dart';

enum _UserEnrollmentRunState {
  idle,
  startingCamera,
  waiting,
  capturing,
  uploading,
  retrying,
  complete,
}

class UserEnrollmentScreen extends StatefulWidget {
  const UserEnrollmentScreen({
    super.key,
    required this.controller,
    this.cameraSession,
  });

  final AppController controller;
  final EnrollmentCameraSession? cameraSession;

  @override
  State<UserEnrollmentScreen> createState() => _UserEnrollmentScreenState();
}

class _UserEnrollmentScreenState extends State<UserEnrollmentScreen> {
  late final EnrollmentCameraSession _cameraSession =
      widget.cameraSession ?? LiveEnrollmentCameraSession();
  final TextEditingController _nameController = TextEditingController();

  GuidedEnrollmentProgress progress = const GuidedEnrollmentProgress();
  String personId = '';
  String? statusText;
  int countdownSeconds = 0;
  _UserEnrollmentRunState runState = _UserEnrollmentRunState.idle;
  Timer? _timer;

  bool get _isActive =>
      runState == _UserEnrollmentRunState.startingCamera ||
      runState == _UserEnrollmentRunState.waiting ||
      runState == _UserEnrollmentRunState.capturing ||
      runState == _UserEnrollmentRunState.uploading ||
      runState == _UserEnrollmentRunState.retrying;

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    unawaited(_cameraSession.dispose());
    super.dispose();
  }

  Future<void> _startEnrollment() async {
    if (_nameController.text.trim().isEmpty || _isActive) return;
    final person = await widget.controller.createUserPerson(
      displayName: _nameController.text.trim(),
    );
    if (!mounted || person == null) return;
    setState(() {
      personId = person.id;
      progress = progress.reset();
      statusText = 'Starting camera.';
    });
    if (!_cameraSession.isReady) await _startCamera();
    if (!mounted || !_cameraSession.isReady) return;
    _scheduleCapture();
  }

  Future<void> _startCamera() async {
    setState(() => runState = _UserEnrollmentRunState.startingCamera);
    try {
      await _cameraSession.initialize();
      if (!mounted) return;
      setState(() {
        runState = _UserEnrollmentRunState.idle;
        statusText = 'Camera ready.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        runState = _UserEnrollmentRunState.idle;
        statusText = 'Camera unavailable.';
      });
    }
  }

  void _scheduleCapture() {
    _timer?.cancel();
    setState(() {
      countdownSeconds = 3;
      runState = _UserEnrollmentRunState.waiting;
      statusText = 'Hold still for ${progress.currentPrompt.title}.';
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (countdownSeconds > 1) {
        setState(() => countdownSeconds--);
        return;
      }
      timer.cancel();
      unawaited(_captureCurrentPrompt());
    });
  }

  Future<void> _captureCurrentPrompt() async {
    setState(() {
      countdownSeconds = 0;
      runState = _UserEnrollmentRunState.capturing;
      statusText = 'Capturing ${progress.currentPrompt.title}.';
    });
    try {
      final capture = await _cameraSession.capture();
      if (!mounted) return;
      setState(() {
        runState = _UserEnrollmentRunState.uploading;
        statusText = 'Checking sample.';
      });
      final template = await widget.controller.uploadUserEnrollmentSample(
        personId: personId,
        fileName: capture.fileName,
        bytes: capture.bytes,
        expectedPose: progress.currentPrompt.poseCode,
      );
      if (!mounted) return;
      if (template == null) {
        _retryCurrentPrompt(widget.controller.value.message);
        return;
      }
      final nextProgress = progress.acceptSample();
      setState(() {
        progress = nextProgress;
        runState = nextProgress.isComplete
            ? _UserEnrollmentRunState.complete
            : _UserEnrollmentRunState.waiting;
        statusText = nextProgress.isComplete
            ? 'Enrollment complete.'
            : 'Sample accepted.';
      });
      if (nextProgress.isComplete) {
        await _cameraSession.dispose();
      } else {
        _scheduleCapture();
      }
    } catch (_) {
      if (!mounted) return;
      widget.controller.showMessage('Could not capture camera sample.');
      setState(() => runState = _UserEnrollmentRunState.idle);
    }
  }

  void _retryCurrentPrompt(String? message) {
    setState(() {
      runState = _UserEnrollmentRunState.retrying;
      statusText =
          '${message ?? 'Sample rejected.'} Retrying ${progress.currentPrompt.title}.';
    });
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) _scheduleCapture();
    });
  }

  void _cancelEnrollment() {
    _timer?.cancel();
    setState(() {
      countdownSeconds = 0;
      runState = _UserEnrollmentRunState.idle;
      statusText = 'Enrollment canceled.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final canStart = !state.isBusy &&
            !_isActive &&
            _nameController.text.trim().isNotEmpty &&
            !progress.isComplete;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Enroll Face', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              enabled: !_isActive && !state.isBusy,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            EnrollmentCameraStage(
              cameraSession: _cameraSession,
              prompt: progress.currentPrompt,
              countdownSeconds: countdownSeconds,
              isStarting: runState == _UserEnrollmentRunState.startingCamera,
              isActive: _isActive,
            ),
            const SizedBox(height: 16),
            EnrollmentActionPanel(
              progress: progress,
              canStart: canStart,
              isActive: _isActive,
              startLabel: 'Start Enrollment',
              onStart: _startEnrollment,
              onCancel: _cancelEnrollment,
            ),
            const SizedBox(height: 16),
            if (state.message != null) ...[
              StatusBanner(label: state.message!, tone: BannerTone.error),
              const SizedBox(height: 12),
            ],
            if (statusText != null)
              StatusBanner(label: statusText!, tone: BannerTone.info),
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 5: Reorder manager shell around People**

Modify `client/lib/screens/shell_screen.dart`.

Add import:

```dart
import 'user_enrollment_screen.dart';
```

Replace the public `onEnrollFace` callback:

```dart
            onEnrollFace: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserEnrollmentScreen(
                  controller: widget.controller,
                ),
              ),
            ),
```

Replace `screens` list:

```dart
        final screens = [
          PeopleScreen(
            controller: widget.controller,
            onAddPerson: () => setState(() => index = 1),
          ),
          EnrollmentScreen(controller: widget.controller),
          CaptureScreen(controller: widget.controller),
          EventsScreen(controller: widget.controller),
          SettingsScreen(controller: widget.controller),
        ];
```

Replace app bar title:

```dart
            title: const Text('Manager'),
```

Replace navigation destinations:

```dart
            destinations: const [
              NavigationDestination(icon: Icon(Icons.people), label: 'People'),
              NavigationDestination(icon: Icon(Icons.badge), label: 'Enroll'),
              NavigationDestination(
                icon: Icon(Icons.photo_camera),
                label: 'Verify',
              ),
              NavigationDestination(icon: Icon(Icons.history), label: 'Events'),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
```

- [ ] **Step 6: Run screen tests to verify they pass**

Run from `client/`:

```bash
flutter test test/client_screen_test.dart
```

Expected: PASS.

- [ ] **Step 7: Run guided enrollment tests to protect pose contract**

Run from `client/`:

```bash
flutter test test/guided_enrollment_test.dart
```

Expected: PASS and prompt order remains unchanged.

- [ ] **Step 8: Commit phase**

```bash
git add client/lib/screens/user_enrollment_screen.dart client/lib/widgets/enrollment_action_panel.dart client/lib/screens/shell_screen.dart client/test/client_screen_test.dart
git commit -m "feat: add simple public face enrollment"
```

## Success Criteria

- Public enrollment captures five samples without login.
- Public enrollment uses existing prompt codes through `progress.currentPrompt.poseCode`.
- Manager shell starts on People and still exposes all manager screens.

## Risk Assessment

- `UserEnrollmentScreen` duplicates timing behavior from manager enrollment. Keep the duplicate only for user-specific simplicity; do not change `guidedEnrollmentPrompts`.

## Security Considerations

- User enrollment uses public endpoint.
- Manager management stays behind login.

## Next Steps

- Continue with Phase 05 verification and docs.

## Unresolved Questions

None.
