# Codebase Summary

## Snapshot

Repository status after first implementation pass:

- Product docs: present
- Application code: backend present, client shell present
- Backend implementation: FastAPI scaffold, API routes, service boundaries, repositories
- Flutter client implementation: shell and tests present
- Database schema: PostgreSQL + pgvector schema file present
- Deployment automation: component setup guides live in each component README

## Observed Files

- [`deep-research-report.md`](../deep-research-report.md) - Vietnamese PRD for the planned product
- [`backend/`](../backend) - FastAPI backend package managed with `uv`
- [`client/`](../client) - Flutter client shell and tests

## Repository Shape

The visible product surface now includes a backend scaffold, Flutter client shell, docs, and active plan files. Hidden assistant/tooling directories are not product implementation scope.

## What The PRD Describes

The PRD defines a local-first access-control system with:

- FastAPI server
- InsightFace + ONNX Runtime GPU inference
- PostgreSQL + pgvector + JSONB
- Flutter mobile as the primary demo client
- Flutter web as a secondary demo client
- 1:N face identification with audit logging

## Implemented Backend Surface

- `/v1/server/health` and `/v1/server/info`
- Local JWT/password helpers and role checks
- People, face template, event, settings, and user repositories
- PostgreSQL schema for users, roles, devices, people, face templates, recognition events, and settings
- Roles and system settings seeded by schema; first admin command is pending
- Upload validation, threshold decisioning, model loader abstraction, enrollment and recognition services
- Unit/API tests runnable through `uv`
- Flutter shell tests documented in the client README

## What Is Missing Or Unverified

- Full Flutter camera/device integration
- Real InsightFace model load and GPU provider smoke
- Full API integration tests for auth, people, enrollment, recognition, events, and config
- End-to-end demo flow
- Client platform run folders

## Interpretation

The repository has moved beyond documentation bootstrap. Future backend work should extend existing modules directly and preserve `uv` as the Python package manager.

## Repomix Notes

An earlier Repomix snapshot was generated during planning. It is historical only; the current repository now includes backend, client shell, tests, docs, and active plan files.

## References

- Backend setup guide: [`../backend/README.md`](../backend/README.md)
- Backend app code: [`../backend/app`](../backend/app)
- Backend package config: [`../backend/pyproject.toml`](../backend/pyproject.toml)
- Client setup guide: [`../client/README.md`](../client/README.md)
- Client app code: [`../client/lib`](../client/lib)
- Client package config: [`../client/pubspec.yaml`](../client/pubspec.yaml)
