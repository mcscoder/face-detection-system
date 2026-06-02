# Client Purpose User Manager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the client into a two-purpose app: unauthenticated user face verify/enroll and authenticated manager user management.

**Architecture:** Public user flows call new unauthenticated `/v1/user/...` backend endpoints that reuse the existing recognition and enrollment services. Manager flows keep the existing login, RBAC, People, Events, Settings, Verify, and Enrollment surfaces. Guided enrollment keeps the existing five prompt contract: `face_forward`, `turn_left`, `turn_right`, `look_up_down`, `natural`.

**Tech Stack:** FastAPI, Pydantic, pytest, Flutter, Material 3, camera, flutter_test.

---

## Protected Requirement

- Keep multi-angle enrollment prompts and backend pose validation unchanged.
- Keep wrong-pose behavior: retry same prompt and do not increment accepted count.
- User mode has no username/password.
- Manager mode uses existing backend login and existing manager/admin capabilities.

## Phases

| Phase | Status | Scope |
|---|---|---|
| [Phase 01](phase-01-public-user-api.md) | planned | Add public backend endpoints for user verify/enroll |
| [Phase 02](phase-02-client-public-api-state.md) | planned | Add client API/controller methods that work without session |
| [Phase 03](phase-03-user-mode-shell.md) | planned | Add user-first shell and public verify flow |
| [Phase 04](phase-04-user-enrollment-and-manager-layout.md) | planned | Add simple user enrollment and manager layout refresh |
| [Phase 05](phase-05-verification-and-docs.md) | planned | Run tests/analyze and update docs |

## Acceptance Criteria

- Opening the app without login shows only `Verify Face`, `Enroll Face`, and manager entry.
- User can verify face without client-side authentication.
- User can enroll face without client-side authentication.
- User enrollment still captures all five existing prompt poses.
- Manager login shows management screens for all users.
- Manager user management still supports list, detail, update, remove, enrollment, events, and settings according to current role permissions.
- `flutter test`, `flutter analyze`, and relevant backend tests pass.

## File Map

- Backend public route: `backend/app/api/routes/user.py`
- Backend router registration: `backend/app/api/router.py`
- Backend tests: `backend/tests/api/test_user_routes.py`
- Client API and demo transport: `client/lib/api/api_client.dart`, `client/lib/api/api_transport.dart`
- Client state: `client/lib/state/app_controller.dart`
- Client shell and user screens: `client/lib/screens/shell_screen.dart`, `client/lib/screens/login_screen.dart`, `client/lib/screens/capture_screen.dart`, `client/lib/screens/user_home_screen.dart`, `client/lib/screens/user_enrollment_screen.dart`
- Client enrollment action label: `client/lib/widgets/enrollment_action_panel.dart`
- Client tests: `client/test/app_controller_test.dart`, `client/test/client_screen_test.dart`
- Docs: `README.md`, `client/README.md`, `docs/codebase-summary.md`, `docs/project-roadmap.md`, `docs/project-changelog.md`, `docs/design-guidelines.md`

## Unresolved Questions

None.
