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
| Backend foundation | in-progress | FastAPI project, config, auth, health endpoints |
| Recognition pipeline | in-progress | Face detect, embed, compare, decision logic |
| Database and schema | in-progress | PostgreSQL schema, pgvector, audit tables |
| Client foundation | in-progress | Flutter mobile and web shells, auth, API wiring |
| Enrollment workflows | planned | Person CRUD, enrollment wizard, template management |
| Recognition UX | planned | Capture flow, match result, error states |
| Testing and hardening | in-progress | Unit, integration, and edge-case coverage |
| Deployment packaging | in-progress | Local setup commands, database schema setup, HTTPS local option |

## Phase Details

### 1. Documentation Baseline

- Status: done
- Deliverables: README, PDR, architecture, standards, roadmap, deployment, design, changelog

### 2. Backend Foundation

- Status: in-progress
- Current note: backend package now uses `uv`; app shell, health/info routes, auth helpers, and settings exist
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
- Current note: schema SQL, repositories, and backend setup guide exist
- Tasks:
  - define `people`, `face_templates`, and `recognition_events`
  - add `pgvector` support
  - add schema setup and indexes
  - define retention-related fields

### 5. Client Foundation

- Status: in-progress
- Current note: Flutter app shell, operational screens, API abstraction, and widget/state tests exist; platform run folders pending
- Tasks:
  - bootstrap Flutter app
  - add mobile-first capture flow
  - add web fallback flow
  - wire HTTP client and auth session handling

### 6. Enrollment And Recognition UX

- Status: planned
- Tasks:
  - person create/edit screens
  - enrollment wizard
  - recognition result screen
  - event and audit views

### 7. Testing And Hardening

- Status: in-progress
- Current note: backend deterministic tests pass, client tests pass, and Flutter analysis is clean; GPU smoke remains pending
- Tasks:
  - unit tests for service logic
  - integration tests for API paths
  - failure-path tests for uploads and recognition
  - security review for sensitive data handling

### 8. Deployment Packaging

- Status: in-progress
- Current note: backend and client setup commands live only in their component READMEs
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
