---
phase: 6
title: "Testing"
status: in-progress
priority: P1
effort: "3d"
dependencies: [2, 3, 4, 5]
---

# Phase 6: Testing

## Context Links

- [`docs/code-standards.md`](../../docs/code-standards.md)
- [`docs/project-overview-pdr.md`](../../docs/project-overview-pdr.md)
- [`deep-research-report.md`](../../deep-research-report.md)

## Overview

Add unit, integration, API, client, and environment smoke tests for the completed v1 path. Focus on failure modes that matter for access control and biometric data handling.

## Key Insights

- Do not fake implementation just to pass tests.
- Real model/GPU tests may need opt-in markers because local hardware varies.
- Core deterministic logic should be tested without requiring the GPU.

## Requirements

- Functional: tests for people CRUD, prompt-gated guided camera enrollment, live camera identify, events, RBAC, upload validation, client result mapping.
- Non-functional: compile/type checks pass, tests can run locally with documented prerequisites.

## Architecture

Test layers:

| Layer | Coverage |
|---|---|
| Unit | services, threshold logic, upload validation, schema shaping |
| Integration | database schema, repositories, API + DB |
| Smoke | model load, `/server/info`, end-to-end sample flow |
| Client | screen states, guided enrollment states, live identify states, API client, auth guards |
| Security | RBAC, upload rejection, data minimization |

## Related Code Files

- Create/modify: `backend/tests/`
- Create/modify: `client/test/`
- Create/modify: `client/integration_test/`

## Implementation Steps

1. Add backend unit tests for config, auth, upload validation, threshold decision, and service result schemas.
2. Add repository/database tests for schema setup, JSONB search, event append, and active template filtering.
3. Add API tests for auth, RBAC, people, enrollment upload errors, identify errors, and events filters.
4. Add deterministic recognition tests with controlled embeddings.
5. Add opt-in smoke test for real InsightFace model loading and provider reporting.
6. Add Flutter widget tests for login, live capture states, result states, guided enrollment prompt/progress states, and role guards.
7. Add client tests for automatic enrollment sample capture, backend-gated advancement, and retry states.
8. Add backend/API tests for enrollment wrong-pose rejection and stable prompt feedback codes.
9. Add one documented end-to-end demo command using real server, database, and client API calls.
10. Run compile/type/test commands and fix failures.

## Todo List

- [x] Backend unit tests pass.
- [x] Database/API integration tests pass.
- [x] Recognition failure-path tests pass.
- [x] Client widget/state/live transport tests pass; client analyze passes.
- [x] GPU/model smoke test documented.
- [x] Guided enrollment prompt/progress tests pass.
- [x] Automatic enrollment sample capture tests pass.
- [x] Live identify camera flow tests pass.
- [x] Backend-gated enrollment advancement tests pass.
- [x] Wrong-pose enrollment rejection tests pass.
- [ ] End-to-end demo command exists.

## Success Criteria

- [x] All non-hardware-gated tests pass locally.
  - [ ] Hardware-gated smoke test can be run manually on NVIDIA host.
- [x] No syntax/compile errors in backend or client.
- [x] Tests cover `NO_FACE`, `MULTIPLE_FACES`, `LOW_SCORE`, invalid upload, unauthorized access, and admin-only data.
- [x] Tests cover guided enrollment prompt order, retry state, and completion state.
- [x] Tests cover live identify camera session start, capture, submit, and result states.
- [x] Tests cover enrollment staying on the same prompt after backend rejection.
- [x] Test data contains no real biometric assets.

## Risk Assessment

- Risk: flaky camera/e2e tests. Mitigation: keep UI tests deterministic and reserve camera hardware checks for manual smoke.
- Risk: local database setup blocks tests. Mitigation: provide clear schema and environment variable commands.

## Security Considerations

- Keep test credentials local and non-secret.
- Do not commit real face images.
- Add regression tests for excessive property exposure in API responses.

## Next Steps

Phase 7 packages the verified app for local demo and operational recovery.
