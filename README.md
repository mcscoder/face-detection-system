# Face Detection System

Local-first face recognition access-control system, planned for one machine with an NVIDIA GPU 8GB.

## Current Status

- Repository state: backend foundation in progress
- Implementation state: FastAPI backend scaffold, schema, service contracts, and tests added
- Existing product source: [`deep-research-report.md`](./deep-research-report.md)
- Current backend code: [`backend/`](./backend)
- Current client code: Flutter shell in [`client/`](./client)
- Current database code: PostgreSQL schema file added

## Target Product

- Server-first face recognition pipeline
- Python FastAPI API as system center
- InsightFace + ONNX Runtime GPU for inference
- PostgreSQL + pgvector + JSONB for people, templates, and events
- Flutter mobile client as primary demo path
- Flutter web client as secondary demo path

## Core Flow

1. Enroll a person with 3-5 face images
2. Generate face templates on the server
3. Identify a probe image with 1:N matching
4. Return `person_id`, `similarity_score`, `threshold`, `event_id`, and `decision`
5. Write an audit event for the decision

## Planned Product Capabilities

- Auth and RBAC
- Person CRUD with flexible metadata
- Face enrollment and re-enrollment
- Recognition API with upload validation
- Audit logs and retention policy
- Local file storage for controlled biometric assets
- Backup and restore for the local machine

## What Is Implemented

- FastAPI app factory with `/v1/server/health` and `/v1/server/info`
- `uv` backend package management with `backend/uv.lock`
- PostgreSQL + pgvector schema file
- Auth/RBAC helpers, API route contracts, repositories, and Pydantic schemas
- Recognition upload validation, decision logic, model loader boundary, enrollment/identify services
- Direct PostgreSQL schema setup path
- Backend unit/API tests for deterministic behavior
- Flutter client shell, demo transport, operational screens, and tests

## What Is Not Built Yet

- Full Flutter camera/device integration
- Real InsightFace/GPU smoke run
- Admin seed command
- Production admin UI completeness
- End-to-end enrollment -> identify demo on target hardware
- Client platform run folders

## Setup Guides

- Backend setup, database setup, backend tests, and backend run: [`backend/README.md`](./backend/README.md)
- Flutter client setup, client tests, analysis, and current run status: [`client/README.md`](./client/README.md)

## Docs Map

- [`docs/project-overview-pdr.md`](./docs/project-overview-pdr.md) - product scope, goals, and acceptance criteria
- [`docs/codebase-summary.md`](./docs/codebase-summary.md) - current repository snapshot and implementation gap
- [`docs/code-standards.md`](./docs/code-standards.md) - implementation standards
- [`docs/system-architecture.md`](./docs/system-architecture.md) - planned architecture and data flow
- [`docs/project-roadmap.md`](./docs/project-roadmap.md) - phased implementation roadmap
- [`docs/deployment-guide.md`](./docs/deployment-guide.md) - planned local deployment path
- [`docs/design-guidelines.md`](./docs/design-guidelines.md) - UI and product design direction
- [`docs/project-changelog.md`](./docs/project-changelog.md) - documentation and project change log

## Source Of Truth

- Product requirements: [`deep-research-report.md`](./deep-research-report.md)
- Documentation: [`docs/`](./docs)

## Notes

- Hidden assistant tooling directories exist in the repository, but they are not part of the product implementation.
- The target stack is partially implemented. GPU/model and client platform paths still need target-host verification.
