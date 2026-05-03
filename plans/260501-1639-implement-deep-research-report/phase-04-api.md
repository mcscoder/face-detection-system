---
phase: 4
title: "API"
status: complete
priority: P1
effort: "4d"
dependencies: [1, 2, 3]
---

# Phase 4: API

## Context Links

- [`deep-research-report.md`](../../deep-research-report.md)
- [`docs/project-overview-pdr.md`](../../docs/project-overview-pdr.md)
- [`docs/code-standards.md`](../../docs/code-standards.md)

## Overview

Expose the v1 HTTP API for auth, people, prompt-gated enrollment, live-camera recognition, events, server info, and config. Enforce role-based access and stable response contracts.

## Key Insights

- Recognition response must be more than boolean.
- Admin-only data includes full profiles, template details, debug matches, threshold changes, and retention config.
- File uploads use `multipart/form-data`; metadata endpoints use JSON.

## Requirements

- Functional: JWT login, RBAC, CRUD people, prompt-gated face enrollment, recognition identify, events query, health/info/config.
- Non-functional: OpenAPI docs accurate, stable error codes, no stack trace leakage, CORS allowlist.

## Architecture

Router groups:

| Router | Endpoints |
|---|---|
| `auth` | `POST /v1/auth/login` |
| `server` | `GET /v1/server/health`, `GET /v1/server/info` |
| `config` | `GET/PATCH /v1/config` with RBAC |
| `people` | CRUD and search |
| `faces` | enrollment and template management |
| `recognitions` | identify and event detail |
| `events` | audit log search |

Response models must hide fields by role.

## Related Code Files

- Create: `backend/app/api/`
- Create: `backend/app/auth/`
- Create: `backend/app/schemas/`
- Create: `backend/tests/api/`

## Implementation Steps

1. Implement password login and JWT issuing for local users.
2. Add dependencies for current user, required role, registered device, and request context.
3. Build people CRUD/search routes with JSONB metadata support.
4. Build enrollment routes: upload face sample with expected prompt target, list templates, disable template, re-enroll placeholder if model changes.
5. Build recognition route `POST /v1/recognitions/identify` with upload validation and event result.
6. Build event query routes with date/person/device filters and role-aware fields.
7. Build config routes for threshold, retention, CORS/device-readable settings.
8. Add API tests for status codes, RBAC, upload failure paths, and response schemas.
9. Add API contract support for enrollment prompt metadata and wrong-pose/quality feedback.

## Todo List

- [x] Auth and RBAC implemented.
- [x] People endpoints implemented.
- [x] Enrollment endpoints implemented.
- [x] Recognition endpoint implemented.
- [x] Event/config endpoints implemented.
- [x] API tests cover happy and failure paths.
- [x] Enrollment sample API accepts expected prompt target metadata.
- [x] Enrollment sample API returns stable prompt feedback for wrong-pose rejection.

## Success Criteria

- [x] OpenAPI shows all v1 routes with typed request/response models.
- [x] Operator can identify but cannot view full admin-only template data.
- [x] Admin can manage people, templates, threshold, and event search.
- [x] Recognition endpoint returns exact contract required by the report.
- [x] Upload errors return stable codes: `INVALID_IMAGE`, `NO_FACE`, `MULTIPLE_FACES`, `LOW_QUALITY`, `LOW_SCORE`.
- [x] Enrollment prompt errors return stable codes including wrong pose or prompt mismatch.

## Risk Assessment

- Risk: auth scope too broad for demo. Mitigation: implement minimal local JWT + role table first.
- Risk: API leaks full profile in recognition response. Mitigation: separate `person_summary` from full person detail schema.

## Security Considerations

- Rate-limit or throttle upload-heavy endpoints if practical.
- Validate CORS origins from config.
- Use authorization checks at endpoint and repository/query levels.
- Never return internal exception details to clients.

## Next Steps

Phase 5 consumes these API contracts from Flutter. Phase 6 hardens tests around RBAC and upload handling.
