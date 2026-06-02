# Public Face Verification Flow Audit

Scope: `client/lib/**`, `client/test/**`

## Current Flow

- `client/lib/widgets/user_home_screen.dart` wires the `Verify Face` tap.
- `client/lib/screens/shell_screen.dart` pushes `CaptureScreen(publicMode: true)`.
- `client/lib/screens/capture_screen.dart::_startCamera` starts the camera on mount.
- `client/lib/screens/capture_screen.dart::_identifyFromCamera` captures one frame from `_cameraSession.capture()` and sends it to `AppController.identifyUserImage`.
- `client/lib/state/app_controller.dart::identifyUserImage` stores the recognition result in shared app state.
- `client/lib/api/api_client.dart::identifyUser` posts multipart form data to `/v1/user/recognitions/identify`.
- `client/lib/api/live_api_transport_io.dart::postMultipart` sends the file as `multipart/form-data` with field name `file` and no bearer token.

## Likely Instability Points

- The verify flow is single-shot: one `takePicture()` call, no countdown, no hold-still window, no frame retry.
- The public guide is visual only: `client/lib/widgets/face_oval_guide.dart` does not inspect face quality.
- `client/lib/models/domain.dart::RecognitionResult.decisionFromText` maps `LOW_SCORE` to `RecognitionDecision.deny`, so a borderline capture becomes a hard rejection in the UI.
- `client/lib/screens/capture_screen.dart` keeps verification result state in shared `AppState.lastResult`, so stale-result handling and retry behavior are split across route entry and the retry button.

## Exact Files/Functions To Modify

- Primary: `client/lib/screens/capture_screen.dart::_identifyFromCamera`, `_startCamera`, `_PublicVerifyCamera`, `_PublicVerifyResult`
- Secondary: `client/lib/services/enrollment_camera_session.dart::LiveEnrollmentCameraSession.initialize`, `capture`
- Secondary: `client/lib/models/domain.dart::RecognitionResult.decisionFromText`
- Secondary: `client/lib/state/app_controller.dart::identifyUserImage`

## Tests Likely Needing Updates

- `client/test/client_screen_test.dart` public verify and capture cases.
- `client/test/app_controller_test.dart` public user methods case.
- `client/test/live_api_transport_test.dart` only if request shape, endpoint, or multipart payload changes.

## Suspected Cause

- Most likely client-side cause: public verify uploads one immediate frame taken at tap time, so any tap-timing, pose, blur, or exposure wobble turns into a low-score decision that the client renders as `Not verified`.

## Unresolved Questions

- Which server decision codes appear in the intermittent failures.
- Whether failures cluster on the first tap after camera start.
- Whether lighting, orientation, or device model correlates with the declines.
