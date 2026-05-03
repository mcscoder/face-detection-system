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

## Current State

- Current transport is demo-only: `lib/api/api_transport.dart`.
- Platform run folders are not present yet.
- Live HTTP transport is not implemented yet.
- Camera/device integration is not implemented yet.
- Android release setup is not documented yet.
- Web run command is pending.

## References

| Area | Reference |
|---|---|
| Flutter quick setup packages | https://docs.flutter.dev/install/quick |
| Flutter Snap package | https://snapcraft.io/install/flutter/ubuntu |
| Flutter CLI commands | https://docs.flutter.dev/reference/flutter-cli |
| Dart dependency download | https://dart.dev/tools/pub/cmd/pub-get |
| Current dependencies | [`pubspec.yaml`](pubspec.yaml) |
| Current API transport | [`lib/api/api_transport.dart`](lib/api/api_transport.dart) |
