---
title: "Implement Deep Research Report"
description: "Build the local-first face recognition access-control system described in deep-research-report.md."
status: in-progress
priority: P2
effort: 20d
tags: [feature, backend, database, frontend, api, auth, infra]
blockedBy: []
blocks: []
created: 2026-05-01
---

# Implement Deep Research Report

## Overview

Implement the product described in [`deep-research-report.md`](../../deep-research-report.md): a single-host local-first face recognition access-control system with FastAPI managed by `uv`, InsightFace + ONNX Runtime GPU, PostgreSQL + pgvector + JSONB, and Flutter mobile/web clients.

Work context: repository root

Scope decision: HOLD. Build the v1 demo path only. Defer commercial-grade liveness/PAD, cloud deployment, multi-machine scaling, HR/attendance workflows, and advanced analytics.

## Cross-Plan Dependencies

No unfinished project or global plans found during scan. This plan has no detected cross-plan blockers.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Foundation](./phase-01-foundation.md) | Complete |
| 2 | [Database](./phase-02-database.md) | Complete |
| 3 | [Recognition](./phase-03-recognition.md) | Complete |
| 4 | [API](./phase-04-api.md) | Complete |
| 5 | [Client](./phase-05-client.md) | In Progress |
| 6 | [Testing](./phase-06-testing.md) | In Progress |
| 7 | [Deployment](./phase-07-deployment.md) | In Progress |

## Dependencies

- Product source: [`deep-research-report.md`](../../deep-research-report.md)
- Current docs: [`docs/project-overview-pdr.md`](../../docs/project-overview-pdr.md), [`docs/system-architecture.md`](../../docs/system-architecture.md), [`docs/code-standards.md`](../../docs/code-standards.md), [`docs/project-roadmap.md`](../../docs/project-roadmap.md)
- Runtime stack: Python FastAPI managed with `uv`, PostgreSQL + pgvector, InsightFace, ONNX Runtime GPU, Flutter
- Target host: one local machine with NVIDIA GPU 8GB

## Execution Strategy

After Phase 1, Phase 2 and the client shell portions of Phase 5 can run in parallel if file ownership is strict. Phase 3 depends on Phase 1 and database contracts from Phase 2. Phase 4 depends on service and repository interfaces. Phase 6 and Phase 7 must validate the integrated system.

## File Ownership Matrix

| Phase | Primary ownership |
|---|---|
| 1 | `backend/`, `client/`, root tooling |
| 2 | `backend/app/db/`, database config |
| 3 | `backend/app/services/recognition*`, storage service |
| 4 | `backend/app/api/`, auth/RBAC, API schemas |
| 5 | `client/` Flutter app |
| 6 | `backend/tests/`, `client/test/`, validation fixtures |
| 7 | deployment docs, backup/restore commands |

## Success Criteria

- FastAPI server starts locally through the backend setup guide and reports model/GPU status.
- PostgreSQL stores people, templates, events, config, and JSONB metadata.
- Enrollment uses a guided live-camera flow that advances only after server validation confirms face presence, single face, quality, and expected prompt pose.
- Recognition returns `event_id`, `matched`, `decision`, `person_id`, `similarity_score`, `threshold`, and minimal person summary.
- Flutter mobile can guide enrollment and live-camera recognition capture over LAN; Flutter web works on localhost.
- Admin-only fields and template/debug data are RBAC protected.
- Recognition events are audited and probe image retention is explicit.
- Tests cover services, API/database paths, recognition failure states, live identify flow, and prompt-gated enrollment states.

## Unresolved Questions

- Confirm whether `buffalo_m` is final v1 model pack or only default candidate.
- Repeat PostgreSQL + pgvector schema setup on each target host before demo.
- Run InsightFace/ONNX Runtime GPU smoke on the NVIDIA host.
- Decide final probe retention window after target-host demo validation; current default is 0 days.
