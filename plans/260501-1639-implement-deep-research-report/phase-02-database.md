---
phase: 2
title: "Database"
status: in-progress
priority: P1
effort: "3d"
dependencies: [1]
---

# Phase 2: Database

## Context Links

- [`deep-research-report.md`](../../deep-research-report.md)
- [`docs/system-architecture.md`](../../docs/system-architecture.md)
- [`docs/code-standards.md`](../../docs/code-standards.md)

## Overview

Implement PostgreSQL schema, pgvector support, repositories, and seed/config data for people, face templates, recognition events, devices, users, roles, and system settings.

## Key Insights

- `people.extra_data` must support flexible metadata.
- `face_templates.embedding` should start as `vector(512)` if selected model output confirms 512 dimensions.
- Every recognition attempt must write an event, including failures.

## Requirements

- Functional: database schema, repository methods, seed admin/user roles, retention config.
- Non-functional: transactional consistency, indexes for common searches, secure sensitive defaults.

## Architecture

Use PostgreSQL as single transactional store. Use pgvector for template matching and JSONB for flexible metadata.

Core tables:

| Table | Purpose |
|---|---|
| `users` / `roles` | operator/admin auth and RBAC |
| `devices` | registered client identity |
| `people` | stable person records and `extra_data` |
| `face_templates` | embeddings, model metadata, active flags |
| `recognition_events` | decisions, scores, threshold, failure reason |
| `system_settings` | threshold, retention, allowed config |

## Related Code Files

- Create: `backend/app/db/`
- Create: `backend/app/repositories/`
- Create: `backend/tests/integration/`

## Implementation Steps

1. Add database dependency.
2. Create initial schema enabling `vector` extension.
3. Create tables for users, roles, devices, people, face templates, events, and settings.
4. Add indexes: people code/name, JSONB GIN, active templates, event created_at, vector search.
5. Implement repository methods for CRUD, template activation, event append, and settings read/write.
6. Seed default roles and threshold config through schema.
7. Add integration tests using a real PostgreSQL test database where available.

## Todo List

- [x] Schema created.
- [x] pgvector extension enabled in schema.
- [x] Repository layer isolates SQL.
- [x] Seed roles/config available in schema.
- [ ] First admin creation command available without a default password.
- [ ] Database integration tests added.

## Success Criteria

- [ ] Fresh database can apply current schema on local PostgreSQL.
- [ ] `people.extra_data` stores and queries flexible metadata.
- [ ] `face_templates` can store active/inactive embeddings with model metadata.
- [ ] `recognition_events` supports matched and failed outcomes.
- [ ] Common query paths have indexes.

## Risk Assessment

- Risk: embedding dimension differs from schema. Mitigation: verify model output before freezing schema or add explicit schema change if changed early.
- Risk: tests depend on local database. Mitigation: provide a clear test DB setup command.

## Security Considerations

- Hash passwords with a modern password hashing library.
- Do not seed a known default admin password; require `FACE_ADMIN_PASSWORD`.
- Soft delete people/templates where possible.
- Keep admin-only columns out of default repository summary methods.

## Next Steps

Phase 3 uses template repositories for matching. Phase 4 exposes repository behavior through authorized APIs.
