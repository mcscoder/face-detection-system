---
phase: 8
title: "Critical Mobile Backend Fixes"
status: complete
priority: P1
effort: "2d"
dependencies: [3, 4, 5, 6]
---

# Phase 8: Critical Mobile Backend Fixes

## Context Links

- [`deep-research-report.md`](../../deep-research-report.md)
- [`phase-03-recognition.md`](./phase-03-recognition.md)
- [`phase-04-api.md`](./phase-04-api.md)
- [`phase-05-client.md`](./phase-05-client.md)
- [`phase-06-testing.md`](./phase-06-testing.md)

## Overview

Fix two blocking mobile demo issues: people records are not actionable from the People tab, and guided enrollment pose prompts are not reliably enforced when the user performs the wrong pose.

## Key Insights

- People management must be operational, not a read-only list.
- Pose prompts must be enforced by backend validation, not trusted client UI text or countdown timing.
- A wrong pose must not create a template and must not advance the enrollment prompt.
- Web is explicitly deferred; do not spend work on Flutter web in this phase.

## Requirements

- Functional: people list opens person detail; user can edit/update person fields; Admin can remove/soft-delete a person; list refreshes after mutations.
- Functional: enrollment rejects turn-right samples when user turns left or stays front-facing; equivalent wrong-pose checks hold for all non-natural prompts.
- Functional: client shows operator-safe rejection feedback and retries the same prompt after `WRONG_POSE`.
- Non-functional: no local AI inference in Flutter; no raw pose/debug internals shown to non-admin users.

## Architecture

People flow:

```text
PeopleScreen -> PersonDetail/Edit UI -> AppController -> ApiClient -> /v1/people endpoints
```

Enrollment flow:

```text
EnrollmentScreen prompt -> expected_pose multipart field -> EnrollmentService pose gate -> template create only on accept
```

## Related Code Files

- Modify: `client/lib/screens/people_screen.dart`
- Create: `client/lib/screens/person_detail_screen.dart`
- Create: `client/lib/screens/person_detail_widgets.dart`
- Modify: `client/lib/state/app_controller.dart`
- Modify: `client/lib/api/api_client.dart`
- Modify: `client/lib/models/domain.dart`
- Modify: `backend/app/services/enrollment/prompt_pose.py`
- Modify: `backend/app/services/enrollment/service.py`
- Modify: `backend/app/services/recognition/model_loader.py`
- Modify/Create: `client/test/`
- Modify/Create: `backend/tests/`

## Implementation Steps

1. Add a failing Flutter widget/controller test proving People tab cannot open detail, update a person, and remove a person.
2. Add API client/controller methods for `GET /v1/people/{person_id}`, `PATCH /v1/people/{person_id}`, and `DELETE /v1/people/{person_id}`.
3. Implement person detail and edit UI from the existing People tab; keep actions role-aware.
4. Refresh people list after update/delete and show operator-safe failure messages.
5. Add backend unit tests for prompt pose gates: turn-right rejects front/left, turn-left rejects front/right, look-up/down rejects neutral, face-forward rejects large yaw.
6. Audit pose extraction from InsightFace output; if pose is unavailable for a pose-specific prompt, reject with `WRONG_POSE`.
7. Fix pose threshold/direction logic so wrong movement cannot pass prompt validation.
8. Add Flutter enrollment tests proving `WRONG_POSE` keeps the same prompt and does not increment accepted sample count.
9. Run backend tests, Flutter tests, Flutter analyze, and Android release APK build.
10. Update plan/docs after verification.

## Todo List

- [x] People detail navigation implemented from People tab.
- [x] Person edit/update implemented and verified.
- [x] Person remove/soft-delete implemented and verified for Admin role.
- [x] Backend pose gate rejects wrong direction and no-movement samples for directional prompts.
- [x] Enrollment `WRONG_POSE` does not create a template.
- [x] Enrollment `WRONG_POSE` keeps the same prompt in the mobile UI.
- [x] Regression tests cover people detail/edit/remove and wrong-pose enforcement.
- [x] Backend tests, Flutter tests/analyze, and Android release APK build pass.

## Verification

- `env UV_CACHE_DIR=/home/mcs/Workspaces/face-detection-system/.uv-cache uv run pytest -q` in `backend`: 49 passed, 2 skipped.
- `flutter test` in `client`: 17 passed.
- `flutter analyze` in `client`: no issues.
- `flutter build apk --release` in `client`: built `build/app/outputs/flutter-apk/app-release.apk`.

## Success Criteria

- Tapping a person opens detail information for that exact person.
- Editing a person persists changes through the backend and refreshes the People tab.
- Removing a person soft-deletes it through the backend and removes it from the visible list.
- On "Turn right", turning left or staying still returns `WRONG_POSE`, creates no template, and keeps the app on "Turn right".
- Equivalent wrong-pose behavior is covered for left, front, and up/down prompts.
- All non-hardware-gated tests pass.

## Risk Assessment

- Risk: InsightFace pose values may be model-pack dependent. Mitigation: add deterministic unit tests around pose gate math and require target-phone smoke before demo sign-off.
- Risk: delete action may be exposed to the wrong role. Mitigation: keep UI role checks aligned with backend RBAC and include widget tests.

## Security Considerations

- Do not bypass backend RBAC for edit/delete actions.
- Do not expose raw pose vectors or internal model diagnostics in operator-facing UI.

## Next Steps

Run target-phone enrollment and identify smoke against the LAN backend.
