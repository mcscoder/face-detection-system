# Codebase Summary

## Snapshot

Repository status after the current implementation pass:

- Product docs: present and synced to the current implementation pass
- Application code: backend present; Flutter client public user mode, Apple-inspired manager mode, guided mobile enrollment, live identify, and People detail/edit/remove flows present
- Verified build/test state: backend tests pass, client tests/analyze pass, Android release APK build passes
- Open verification gaps: manual target-phone enrollment smoke, target-host database/GPU smoke, full end-to-end hardware audit, Flutter web platform folder
- Backend implementation: FastAPI foundation, auth/RBAC helpers, server health/info routes, role-gated active template count, people metadata filters, service boundaries, repositories
- Flutter client implementation: public user verify/enroll mode, Apple-like light manager shell, Android platform files, demo/live API transports, live camera identify capture, prompt-gated guided camera enrollment, People detail/edit/remove, multipart filename sanitization, and tests present
- Database schema: PostgreSQL + pgvector schema file present
- Deployment automation: component setup guides live in each component README

## Observed Files

- [`deep-research-report.md`](../deep-research-report.md) - Vietnamese PRD for the planned product
- [`backend/`](../backend) - FastAPI backend package managed with `uv`
- [`client/`](../client) - Flutter client shell, guided enrollment flow, live identify flow, and tests
- [`repomix-output.xml`](../repomix-output.xml) - current repository snapshot used for this summary

## Repository Shape

The visible product surface now includes a backend foundation, Flutter client shell, docs, and active plan files. Hidden assistant/tooling directories are not product implementation scope.

## What The PRD Describes

The PRD defines a local-first access-control system with:

- FastAPI server
- InsightFace + ONNX Runtime GPU inference
- PostgreSQL + pgvector + JSONB
- Flutter mobile as the primary demo client
- Flutter web as a secondary demo client
- 1:N face identification with audit logging

## Implemented Backend Surface

- `/v1/server/health` and `/v1/server/info`, with `active_template_count` returned only for authenticated admin/operator/enrollment users, `null` for anonymous requests, and deleted people excluded from the count
- Local JWT/password helpers and role checks
- People, face template, event, settings, and user repositories
- PostgreSQL schema for users, roles, devices, people, face templates, recognition events, and settings
- Roles and system settings seeded by schema; first admin command runs from `backend/` with `FACE_ADMIN_PASSWORD`
- People list metadata filters via `metadata_key` and `metadata_value`
- Upload validation, threshold decisioning, model loader abstraction, enrollment prompt pose validation, and recognition services
- Unit/API tests runnable through `uv`; database and GPU smoke tests are opt-in and skip unless env vars are set

## Implemented Client Surface

- `client/lib/main.dart` selects demo or live transport from `FACE_API_BASE_URL` or `env/mobile.json`
- `client/lib/api/live_api_transport_io.dart` sends multipart uploads with sanitized filenames
- `client/lib/screens/people_screen.dart` and `person_detail_*.dart` open person detail, update fields, and remove Admin-selected people through backend routes
- Manager Dashboard, People, Events, Settings, Enrollment, and Face Check screens now use the Apple-style light neutral shell with system-blue accents and rounded 8px surfaces
- `client/lib/screens/capture_screen.dart` uses a live camera session for identify uploads
- `client/lib/screens/enrollment_screen.dart` uses a live camera session for prompt-gated guided enrollment uploads and stays on the same prompt after `WRONG_POSE`
- Client tests cover controller state, live transport behavior, and screen actions
- Android release APK build passes

## What Is Missing Or Unverified

- Manual target-phone enrollment smoke
- Real InsightFace model load and GPU provider smoke
- Target-host database and GPU smoke execution
- Full end-to-end enrollment -> identify audit on target hardware
- Flutter web platform run folder

## Interpretation

The repository has moved beyond documentation bootstrap. Future backend work should extend existing modules directly and preserve `uv` as the Python package manager.

## Repomix Notes

Fresh Repomix snapshot generated for this docs sync. The earlier planning snapshot is historical only. Repomix excluded `backend/app/core/config.py` from the packed output because it flagged a security issue.

## References

- Backend setup guide: [`../backend/README.md`](../backend/README.md)
- Backend app code: [`../backend/app`](../backend/app)
- Backend package config: [`../backend/pyproject.toml`](../backend/pyproject.toml)
- Client setup guide: [`../client/README.md`](../client/README.md)
- Client app code: [`../client/lib`](../client/lib)
- Client package config: [`../client/pubspec.yaml`](../client/pubspec.yaml)
