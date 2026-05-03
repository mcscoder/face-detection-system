# Setup

Setup guide for this app.

Target system: Ubuntu 22.04.

## 1. Install System Packages

```bash
sudo apt update
```

Refreshes Ubuntu package indexes.

```bash
sudo apt install -y snapd curl git unzip xz-utils zip libglu1-mesa
```

Installs packages used by Flutter setup. `-y` answers yes to the install prompt.

## 2. Install Flutter

```bash
sudo snap install flutter --classic
```

Installs the Flutter SDK from Snap. `--classic` allows classic snap confinement.

Open a new terminal.

```bash
flutter --version
```

Checks that Flutter works.

## 3. Check Flutter Environment

```bash
flutter doctor
```

Checks missing Flutter platform dependencies.

## 4. Install Project Dependencies

```bash
flutter pub get
```

Downloads Dart and Flutter dependencies from `pubspec.yaml`.

## 5. Run Tests

```bash
flutter test
```

Runs Flutter tests.

## 6. Analyze Code

```bash
flutter analyze
```

Checks Dart/Flutter code for static analysis issues.

## 7. Live API Transport

The app reads `env/mobile.json` at startup.

Current mobile backend URL:

```text
http://192.168.1.13:8000/
```

Mobile LAN smoke command:

```bash
flutter run
```

Android release APK command:

```bash
flutter build apk --release
```

Local web smoke command after web platform files exist:

```bash
flutter run -d chrome
```

`-d chrome` selects the Chrome device target.
`FACE_API_BASE_URL` passed through `--dart-define` overrides `env/mobile.json`.

## Current State

- Demo transport remains available when no backend URL is configured: `lib/api/api_transport.dart`.
- Live HTTP transport exists: `lib/api/live_api_transport.dart`, with multipart filename sanitization.
- Capture opens one live camera session and uploads camera captures to `/v1/recognitions/identify`.
- Enrollment creates a person, opens one live camera session, guides five prompts, and uploads samples with expected prompt metadata to `/v1/faces/{person_id}/samples`.
- Flutter tests, analysis, and Android release APK build pass.
- Android platform files are present.
- Manual target-phone enrollment smoke is still unverified.
- Web platform files are not present yet.

## References

| Area | Reference |
|---|---|
| Flutter quick setup packages | https://docs.flutter.dev/install/quick |
| Flutter Snap package | https://snapcraft.io/install/flutter/ubuntu |
| Flutter CLI commands | https://docs.flutter.dev/reference/flutter-cli |
| Dart dependency download | https://dart.dev/tools/pub/cmd/pub-get |
| Current dependencies | [`pubspec.yaml`](pubspec.yaml) |
| Current API transport | [`lib/api/api_transport.dart`](lib/api/api_transport.dart) |
| Live API transport | [`lib/api/live_api_transport.dart`](lib/api/live_api_transport.dart) |
