# Live User Face Check Implementation Plan

**Goal:** Public verify starts checking as soon as camera ready and stabilizes decisions by checking multiple live frames.

**Architecture:** Keep backend contract unchanged. Update public `CaptureScreen` flow to auto-run a short repeated-frame loop, hide intermediate decisions, stop early on `ALLOW`, and show final result only after loop finishes.

**Tech Stack:** Flutter, Dart widget tests, existing `EnrollmentCameraSession`, `AppController`, `ApiClient`.

---

### Task 1: Red Test

**Files:**
- Modify: `client/test/client_screen_test.dart`

- [ ] Add a widget test where public verify auto-captures without tapping and stops after a second-frame `ALLOW`.
- [ ] Use a test transport returning `DENY` for first upload and `ALLOW` for second upload.
- [ ] Run `flutter test test/client_screen_test.dart`.
- [ ] Expected: fail because current UI waits for `Scan Face` and stops after first result.

### Task 2: Implementation

**Files:**
- Modify: `client/lib/screens/capture_screen.dart`

- [ ] Add public-only live check state.
- [ ] Start the public live check after camera initializes.
- [ ] Capture up to five frames, call existing public identify API, and stop early on `ALLOW`.
- [ ] Keep intermediate results hidden while checking.
- [ ] Keep manager `Check Face` behavior unchanged.

### Task 3: Verification

**Files:**
- Modify if needed: `client/README.md`, `docs/project-changelog.md`

- [ ] Run `flutter test test/client_screen_test.dart`.
- [ ] Run `flutter test`.
- [ ] Run `flutter analyze`.
- [ ] Update docs only if behavior text changes.

Unresolved questions: none.
