# Verify Contract Report

Primary sources: backend route/service/tests. Secondary sources: client transport/model/tests. I treated route handlers and unit tests as authoritative for contract and semantics.

## Endpoint

- Public verify is `POST /v1/user/recognitions/identify` via `/v1` + `/user` + `/recognitions/identify`. It takes a required multipart `file` upload and an optional `device_id` query param. There is no auth dependency on this route. See [`backend/app/api/routes/user.py`](../../backend/app/api/routes/user.py#L96).

## Request / Response

- Request fields: multipart form with `file` only for verify. No `enrollment_key`, no `expected_pose`, no JSON body.
- Public response fields: `event_id`, `matched`, `decision`, `threshold`, optional `failure_reason`. The public route strips `person_id`, `face_template_id`, `similarity_score`, and `person_summary` even though the shared recognition service produces them. See [`backend/app/api/routes/user.py`](../../backend/app/api/routes/user.py#L160) and [`backend/app/services/recognition/service.py`](../../backend/app/services/recognition/service.py#L62).
- Private operator verify keeps the richer `RecognitionResponse` shape, including `person_id`, `face_template_id`, `similarity_score`, and `person_summary`. See [`backend/app/schemas/recognition.py`](../../backend/app/schemas/recognition.py#L26).

## Decision Semantics

- `ALLOW` when `similarity_score >= threshold`.
- `REVIEW` when `threshold * 0.9 <= similarity_score < threshold`.
- `DENY` when score is below that band or missing.
- `failure_reason` is `LOW_SCORE` for low-score/no-match cases, `NO_FACE`, `MULTIPLE_FACES`, or `LOW_QUALITY` for model extraction failures, and `MODEL_UNAVAILABLE` for 503 paths.
- These semantics are backed by unit tests in [`backend/tests/unit/test_decision.py`](../../backend/tests/unit/test_decision.py#L4) and [`backend/tests/unit/test_recognition_service.py`](../../backend/tests/unit/test_recognition_service.py#L50).

## Client Live Transport

- `LiveApiTransportIo` sends each capture as its own multipart POST, sets `multipart/form-data`, sanitizes the filename, and infers `image/png` vs `image/jpeg` from the filename suffix. See [`client/lib/api/live_api_transport_io.dart`](../../client/lib/api/live_api_transport_io.dart#L81).
- `ApiClient.identifyUser()` calls that transport once per capture against `/v1/user/recognitions/identify`. See [`client/lib/api/api_client.dart`](../../client/lib/api/api_client.dart#L163).
- `CaptureScreen` public mode triggers exactly one capture per tap today; repeated-frame verification would be a client loop over repeated `capture()` + `identifyUserImage()` calls, not a transport feature. See [`client/lib/screens/capture_screen.dart`](../../client/lib/screens/capture_screen.dart#L85) and [`client/lib/services/enrollment_camera_session.dart`](../../client/lib/services/enrollment_camera_session.dart#L67).

## Client Interpretation Gap

- `RecognitionResult.fromJson()` reads `failure_reason` before `decision`, so a backend `REVIEW` with `failure_reason = LOW_SCORE` is parsed by the client as `deny`. See [`client/lib/models/domain.dart`](../../client/lib/models/domain.dart#L120).
- Public verify responses also omit `similarity_score`, so the client cannot do score-based aggregation from the public contract alone.

## Conclusion

- Client-side repeated-frame verification can be implemented without backend transport changes if it only needs multiple independent uploads and vote-style aggregation on the returned `decision`.
- Backend/public response changes are needed if the feature must preserve `REVIEW` as a distinct state in the client or if it must aggregate by similarity score.

## Unresolved Questions

- Should public verify surface `REVIEW` as a separate UI state, or collapse it into retry/deny?
- Should repeated-frame consensus use majority vote, consecutive-allow, or score averaging?
