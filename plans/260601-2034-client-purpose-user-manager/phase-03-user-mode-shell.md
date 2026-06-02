# Phase 03 User Mode Shell

## Context Links

- App shell: `client/lib/screens/shell_screen.dart`
- Login screen: `client/lib/screens/login_screen.dart`
- Capture screen: `client/lib/screens/capture_screen.dart`
- Existing screen tests: `client/test/client_screen_test.dart`

## Overview

- Priority: high
- Current status: planned
- Make the app open in simple public user mode, with manager login as a secondary entry.

## Key Insights

- Current shell shows login immediately when no session exists.
- User mode needs no login, so shell must route unauthenticated users to a public home.
- Manager UI can remain login-gated after pressing Manager.

## Requirements

- App opens to public user home.
- Public home shows only `Verify Face`, `Enroll Face`, and Manager icon.
- Public verify uses live camera and no session token.
- Manager button opens login.
- Successful login shows manager shell.

## Architecture

`ShellScreen` owns a local `showManagerLogin` flag. When logged out, it displays either `UserHomeScreen` or `LoginScreen`; when logged in, it displays manager navigation.

## Related Code Files

- Create: `client/lib/screens/user_home_screen.dart`
- Modify: `client/lib/screens/shell_screen.dart`
- Modify: `client/lib/screens/login_screen.dart`
- Modify: `client/lib/screens/capture_screen.dart`
- Test: `client/test/client_screen_test.dart`

## Implementation Steps

- [ ] **Step 1: Write shell and public verify tests**

Append to `client/test/client_screen_test.dart`:

```dart
  testWidgets('shell opens in public user mode without login', (tester) async {
    await _setLargeSurface(tester);
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await tester.pumpWidget(MaterialApp(home: ShellScreen(controller: controller)));
    await tester.pump();

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

    await tester.pumpWidget(MaterialApp(home: ShellScreen(controller: controller)));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.admin_panel_settings));
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('People'), findsWidgets);

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
    await tester.tap(find.text('Verify Face'));
    await tester.pumpAndSettle();

    expect(controller.value.isLoggedIn, isFalse);
    expect(camera.captureCount, 1);
    expect(controller.value.lastResult?.eventId, 'evt-demo');

    controller.dispose();
  });
```

Add this import to `client/test/client_screen_test.dart`:

```dart
import 'package:face_detection_client/screens/shell_screen.dart';
```

- [ ] **Step 2: Run screen tests to verify they fail**

Run from `client/`:

```bash
flutter test test/client_screen_test.dart
```

Expected: FAIL because `UserHomeScreen` and `CaptureScreen.publicMode` do not exist.

- [ ] **Step 3: Create public user home screen**

Create `client/lib/screens/user_home_screen.dart`:

```dart
import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({
    super.key,
    required this.onVerifyFace,
    required this.onEnrollFace,
    required this.onManagerLogin,
  });

  final VoidCallback onVerifyFace;
  final VoidCallback onEnrollFace;
  final VoidCallback onManagerLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Face ID',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Manager',
                        onPressed: onManagerLogin,
                        icon: const Icon(Icons.admin_panel_settings),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _UserActionCard(
                    icon: Icons.face,
                    label: 'Verify Face',
                    onTap: onVerifyFace,
                  ),
                  const SizedBox(height: 12),
                  _UserActionCard(
                    icon: Icons.badge,
                    label: 'Enroll Face',
                    onTap: onEnrollFace,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserActionCard extends StatelessWidget {
  const _UserActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Row(
            children: [
              Icon(icon, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Update login screen to support back to user mode**

Modify `client/lib/screens/login_screen.dart`.

Change constructor and fields:

```dart
  const LoginScreen({super.key, required this.controller, this.onBack});

  final AppController controller;
  final VoidCallback? onBack;
```

Add this widget before the `Text('Face Detection'...)` block in the column:

```dart
                      if (widget.onBack != null) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Back',
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
```

- [ ] **Step 5: Update capture screen for public verify**

Modify `client/lib/screens/capture_screen.dart`.

Change constructor and field:

```dart
  const CaptureScreen({
    super.key,
    required this.controller,
    this.cameraSession,
    this.publicMode = false,
  });

  final AppController controller;
  final EnrollmentCameraSession? cameraSession;
  final bool publicMode;
```

Replace the upload call in `_identifyFromCamera`:

```dart
      if (widget.publicMode) {
        await widget.controller.identifyUserImage(
          fileName: capture.fileName,
          bytes: capture.bytes,
        );
      } else {
        await widget.controller.identifyImage(
          fileName: capture.fileName,
          bytes: capture.bytes,
        );
      }
```

Add before `return ListView` in `build`:

```dart
        final actionLabel = widget.publicMode ? 'Verify Face' : 'Check Face';
```

Replace the button label:

```dart
              label: Text(isActive ? 'Checking...' : actionLabel),
```

- [ ] **Step 6: Update shell routing**

Modify `client/lib/screens/shell_screen.dart`.

Add import:

```dart
import 'user_home_screen.dart';
```

Add state field:

```dart
  bool showManagerLogin = false;
```

Replace the logged-out branch:

```dart
        if (!state.isLoggedIn) {
          if (showManagerLogin) {
            return LoginScreen(
              controller: widget.controller,
              onBack: () => setState(() => showManagerLogin = false),
            );
          }
          return UserHomeScreen(
            onVerifyFace: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CaptureScreen(
                  controller: widget.controller,
                  publicMode: true,
                ),
              ),
            ),
            onEnrollFace: () {},
            onManagerLogin: () => setState(() => showManagerLogin = true),
          );
        }
```

Replace logout action:

```dart
                onPressed: () {
                  widget.controller.logout();
                  setState(() => showManagerLogin = false);
                },
```

- [ ] **Step 7: Run screen tests to verify they pass**

Run from `client/`:

```bash
flutter test test/client_screen_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit phase**

```bash
git add client/lib/screens/user_home_screen.dart client/lib/screens/shell_screen.dart client/lib/screens/login_screen.dart client/lib/screens/capture_screen.dart client/test/client_screen_test.dart
git commit -m "feat: add public user app entry"
```

## Success Criteria

- No-session app state displays user home, not login.
- Public verify calls the public controller method.
- Manager entry still reaches login and manager shell.

## Risk Assessment

- Phase 03 wires only public verify. Phase 04 replaces the empty enroll callback with public enrollment navigation.

## Security Considerations

- Public verify does not use bearer token.
- Manager shell still requires successful login.

## Next Steps

- Continue with Phase 04 simple public enrollment and manager layout refresh.

## Unresolved Questions

None.
