# Project Roadmap

## Status Legend

- `done` - completed
- `planned` - not started
- `in-progress` - active
- `blocked` - waiting on dependency

## Roadmap

| Phase | Status | Outcome |
|---|---|---|
| Documentation baseline | done | Core docs created and aligned to PRD |
| Backend foundation | in-progress | FastAPI project, config, auth, health/info endpoints, metadata filters, admin seed command |
| Recognition pipeline | in-progress | Face detect, embed, compare, decision logic |
| Database and schema | in-progress | PostgreSQL schema, pgvector, audit tables, metadata query path |
| Client foundation | in-progress | Flutter Android shell, auth, demo/live API wiring, live identify upload, guided enrollment |
| Enrollment workflows | in-progress | Guided live-camera enrollment exists; edit/template management pending |
| Recognition UX | in-progress | Live camera capture upload, match result, error states |
| Testing and hardening | in-progress | Unit/API coverage plus opt-in database and GPU smoke tests |
| Deployment packaging | in-progress | Local setup, admin seed, backup/restore, GPU smoke commands |

## Phase Details

### 1. Documentation Baseline

- Status: done
- Deliverables: README, PDR, architecture, standards, roadmap, deployment, design, changelog

### 2. Backend Foundation

- Status: in-progress
- Current note: backend package now uses `uv`; app shell, health/info routes, auth helpers, role-gated `active_template_count`, metadata filters, settings, and admin seed command exist
- Tasks:
  - create FastAPI project layout
  - add auth and RBAC skeleton
  - add health and info endpoints
  - add config and logging

### 3. Recognition Pipeline

- Status: in-progress
- Current note: model loader boundary, upload validation, threshold decision, and identify service exist; real model smoke pending
- Tasks:
  - load InsightFace model
  - configure ONNX Runtime GPU
  - add face validation and quality checks
  - implement embedding and similarity logic

### 4. Database And Schema

- Status: in-progress
- Current note: schema SQL, repositories, metadata filters, and backend setup guide exist; active template counts exclude deleted people
- Tasks:
  - define `people`, `face_templates`, and `recognition_events`
  - add `pgvector` support
  - add schema setup and indexes
  - define retention-related fields

### 5. Client Foundation

- Status: in-progress
- Current note: Flutter app shell, Android platform files, operational screens, demo/live API abstraction, live-camera identify upload, prompt-gated guided live-camera enrollment, multipart filename sanitization, and widget/state tests exist; client tests/analyze pass; web platform files and manual target-phone smoke pending
- Tasks:
  - bootstrap Flutter app
  - add mobile-first capture flow
  - add web fallback flow
  - wire HTTP client and auth session handling

### 6. Enrollment And Recognition UX

- Status: in-progress
- Current note: client can create people, guide five live-camera enrollment prompts with backend-gated sample upload, and upload live-camera captures to identify; target-phone enrollment smoke and full end-to-end audit verification remain pending
- Tasks:
  - person create/edit screens
  - guided enrollment flow
  - recognition result screen
  - event and audit views

### 7. Testing And Hardening

- Status: in-progress
- Current note: backend deterministic tests pass, client tests/analyze pass, Android release APK build passes, and database/GPU smoke tests are opt-in and skip unless env vars are set
- Tasks:
  - unit tests for service logic
  - integration tests for API paths
  - failure-path tests for uploads and recognition
  - security review for sensitive data handling

### 8. Deployment Packaging

- Status: in-progress
- Current note: backend/client setup, admin seed, backup/restore, database smoke, GPU smoke, and release APK build commands are documented; target-phone and end-to-end hardware verification remain pending
- Tasks:
  - local install guide
  - database backup and restore command
  - GPU dependency notes
  - optional HTTPS local path for web camera access

## Near-Term Priority

1. Backend foundation
2. Database schema
3. Recognition pipeline
4. Client shell
5. Tests

## Roadmap Notes

- Keep implementation local-first
- Keep the server as the only inference site
- Keep docs updated when a phase changes status

## References

- Backend setup guide: [`../backend/README.md`](../backend/README.md)
- Client setup guide: [`../client/README.md`](../client/README.md)
- Active implementation plan: [`../plans/260501-1639-implement-deep-research-report/plan.md`](../plans/260501-1639-implement-deep-research-report/plan.md)
