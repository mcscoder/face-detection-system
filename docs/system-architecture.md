# System Architecture

## Status

Backend foundation and Flutter client shell are partially implemented. Full client integration and target-host GPU verification remain pending.

## Architecture Overview

Single-host local-first system.

- One machine runs the server, database, storage, and GPU inference
- Clients connect over HTTP
- Client side does capture and UI only
- Server side owns all recognition and data decisions

## Component Map

| Component | Role |
|---|---|
| FastAPI API | Auth, CRUD, enrollment, recognition, events |
| Recognition service | Face detect, align, embed, compare |
| Enrollment service | Quality checks and template creation |
| PostgreSQL | People, templates, events, config |
| `pgvector` | Vector search for embeddings |
| Local storage | Controlled storage for enrollment and audit artifacts |
| Flutter mobile | Primary demo client |
| Flutter web | Secondary demo client |

## Current Implementation Map

| Path | Status |
|---|---|
| `backend/app/api/` | v1 route contracts and server health/info routes |
| `backend/app/services/recognition/` | upload validation, model boundary, decision logic, identify service |
| `backend/app/services/enrollment/` | template creation service boundary |
| `backend/app/repositories/` | SQL repository methods for planned tables |
| `backend/app/db/schema.sql` | PostgreSQL + pgvector schema |

## Data Flow

1. Client captures or uploads an image
2. API validates request and access
3. Server detects faces
4. Server rejects invalid face count or poor input
5. Server extracts embedding with InsightFace
6. Server searches enrolled templates in PostgreSQL
7. Server computes similarity and compares threshold
8. Server writes an event row
9. Server returns decision and stable identity data

## Planned Server Responsibilities

- Authentication and authorization
- People CRUD
- Enrollment and re-enrollment
- Identification and decisioning
- Audit and event history
- Threshold and config management
- Storage lifecycle control

## Planned Client Responsibilities

- Login
- Camera and upload UI
- Result display
- Admin forms
- Basic history views

## Storage Model

- `people` table for identity records
- `face_templates` table for embeddings
- `recognition_events` table for decisions and audit
- `jsonb` fields for flexible metadata

## Deployment Shape

- Primary path: Flutter mobile app to local API over LAN
- Secondary path: Flutter web on localhost or HTTPS local
- No cloud dependency in v1

## Key Constraints

- GPU memory is limited to 8GB
- Inference should run in a single main process
- Probe retention should be minimal by default
- Web camera access may require secure context

## References

- Product source: [`../deep-research-report.md`](../deep-research-report.md)
- Backend API routes: [`../backend/app/api`](../backend/app/api)
- Recognition services: [`../backend/app/services/recognition`](../backend/app/services/recognition)
- Database schema: [`../backend/app/db/schema.sql`](../backend/app/db/schema.sql)
- Client screens: [`../client/lib/screens`](../client/lib/screens)
