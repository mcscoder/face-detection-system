# API Provider Dropdown Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a public home screen dropdown that switches the Flutter app between two fixed API providers.

**Architecture:** Keep provider definitions in a small API config file. Let the app own the selected provider and recreate the controller transport when it changes. Render a compact dropdown in the public home top row.

**Tech Stack:** Flutter, Dart, existing `ApiTransport`, existing widget tests.

---

### Task 1: Home Provider Dropdown

**Files:**
- Create: `client/lib/api/api_provider.dart`
- Modify: `client/lib/app.dart`
- Modify: `client/lib/main.dart`
- Modify: `client/lib/screens/shell_screen.dart`
- Modify: `client/lib/screens/user_home_screen.dart`
- Test: `client/test/client_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add a test that pumps `ShellScreen`, expects `API` dropdown, switches to ngrok, and verifies callback.

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/client_screen_test.dart`

- [x] **Step 3: Implement provider model and app wiring**

Add fixed providers and recreate `AppController` when selected provider changes.

- [x] **Step 4: Implement compact home dropdown**

Place the dropdown in the public home top row.

- [x] **Step 5: Run verification**

Run: `dart format`, `flutter test`, and `flutter analyze`.
