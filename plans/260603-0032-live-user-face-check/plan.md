---
title: "Live Public Face Check"
description: "Concise client-only plan to replace tap-to-start public verify with repeated live checks."
status: pending
priority: P1
effort: 4h
branch: main
tags: [flutter, client, face-verification, public-mode]
created: 2026-06-03
---

# Live Public Face Check Plan

- Scope: client-only unless blocked; backend already accepts repeated single-image calls at [backend/app/api/routes/user.py](/home/mcs/Workspaces/face-detection-system/backend/app/api/routes/user.py:96) and the client already posts one probe per call at [client/lib/api/api_client.dart](/home/mcs/Workspaces/face-detection-system/client/lib/api/api_client.dart:163).
- Current flow: public verify opens [CaptureScreen](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:54), user taps `Scan Face` at [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:265), `_identifyFromCamera()` captures one frame at [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:85), then `identifyUserImage()` at [client/lib/state/app_controller.dart](/home/mcs/Workspaces/face-detection-system/client/lib/state/app_controller.dart:100) posts to `/v1/user/recognitions/identify`.
- Data flow target: camera ready -> sequential `capture()` from [client/lib/services/enrollment_camera_session.dart](/home/mcs/Workspaces/face-detection-system/client/lib/services/enrollment_camera_session.dart:17) -> `identifyUserImage()` -> inspect `RecognitionDecision` from [client/lib/models/domain.dart](/home/mcs/Workspaces/face-detection-system/client/lib/models/domain.dart:103) -> stop on `allow`, else continue until max attempts then show final result.
- Assumptions: auto-start on public-screen open, fixed cap of 3 sequential attempts, manager path in [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:151) stays unchanged.

## TODO

- [ ] Task 1: Update the public branch in [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:121) to start live checks after camera init and remove tap-to-start as the primary trigger.
- [ ] Task 2: Keep repeated-check state inside `CaptureScreen`; gate [_PublicVerifyResult](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:315) so intermediate failed attempts do not replace the preview before first `ALLOW` or attempt-cap exhaustion.
- [ ] Task 3: Reuse [client/lib/state/app_controller.dart](/home/mcs/Workspaces/face-detection-system/client/lib/state/app_controller.dart:100) and [client/lib/api/api_client.dart](/home/mcs/Workspaces/face-detection-system/client/lib/api/api_client.dart:163); clear stale result/message between attempts only if needed, no backend contract change.
- [ ] Task 4: Update widget coverage in [client/test/client_screen_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/client_screen_test.dart:120) using the existing fake camera seam at [client/test/client_screen_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/client_screen_test.dart:683) and transport override pattern at [client/test/client_screen_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/client_screen_test.dart:822).

## Dependencies / Ownership

- Task 1 blocks Tasks 2-4.
- Product file ownership: `client/lib/screens/capture_screen.dart`.
- Test file ownership: `client/test/client_screen_test.dart`; touch [client/test/app_controller_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/app_controller_test.dart:59) only if the controller signature must change after implementation spike.
- `identifyUserImage()` caller list: prod at [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:96); test-only setup at [client/test/app_controller_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/app_controller_test.dart:71), [client/test/client_screen_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/client_screen_test.dart:166), and [client/test/client_screen_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/client_screen_test.dart:193).

## Risks / Mitigation

- High: auto-loop can race after dispose or retry; mitigate with mounted checks, loop token, and one active capture/request.
- Medium: intermediate non-allow results can flash terminal UI; mitigate by separating attempt state from final-result state in public mode.
- Medium: repeated probes increase request count; mitigate with fixed 3-attempt cap and no parallel requests.

## Backward Compatibility / Rollback

- Manager identify flow at [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:151) remains unchanged.
- Public API path and response shape from [backend/app/api/routes/user.py](/home/mcs/Workspaces/face-detection-system/backend/app/api/routes/user.py:35) remain unchanged.
- Roll back by reverting `client/lib/screens/capture_screen.dart` and `client/test/client_screen_test.dart` together.

## Test Matrix / Verification

- Widget: auto-starts without tap; retries until allow; stops at cap and shows last failure; retry starts a fresh loop; stale result still clears on open.
- Controller/API regression: keep existing public method coverage in [client/test/app_controller_test.dart](/home/mcs/Workspaces/face-detection-system/client/test/app_controller_test.dart:59).
- Manual: open `Verify Face`, confirm camera starts, registered face can pass before cap, unregistered face reaches capped failure without taps.
- Commands in `client/`: `flutter test test/client_screen_test.dart`, `flutter test test/app_controller_test.dart`, `flutter analyze`.

## Success Criteria

- Public verify no longer requires tapping `Scan Face`.
- First `ALLOW` stops the loop and shows `Verified`.
- Non-allow results retry automatically up to 3 times, then show the last public result.
- No backend files change.
- The listed Flutter tests and analysis pass.

## Unresolved Questions

- None.
