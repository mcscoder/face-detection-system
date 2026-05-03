---
phase: 1
title: "Foundation"
status: complete
priority: P1
effort: "3d"
dependencies: []
---

# Phase 1: Foundation

## Context Links

- [`deep-research-report.md`](../../deep-research-report.md)
- [`docs/codebase-summary.md`](../../docs/codebase-summary.md)
- [`docs/code-standards.md`](../../docs/code-standards.md)
- [`docs/system-architecture.md`](../../docs/system-architecture.md)

## Overview

Create the initial project structure, backend and client shells, config strategy, and developer commands. No recognition behavior yet; this phase makes the repo runnable and keeps future files small and separable.

## Key Insights

- Repo has no product code yet.
- Server owns inference and decisions; clients only capture/administer.
- Keep one GPU inference process in later phases to avoid duplicated VRAM use.

## Requirements

- Functional: backend app shell, Flutter app shell, health endpoint placeholder, local config loading, logging.
- Non-functional: clear module boundaries, files under 200 lines when practical, reproducible setup commands.
- Package management: Python backend dependencies must use `uv`; backend setup commands live only in the backend README.

## Architecture

Use a simple monorepo layout:

| Area | Path | Purpose |
|---|---|---|
| Backend | `backend/` | FastAPI app, services, db, tests |
| Client | `client/` | Flutter mobile/web app |
| Docs | `docs/` | synced implementation docs |

Backend layers: API routers -> service layer -> repository/db layer. Recognition stays behind service interfaces.

## Related Code Files

- Create: `backend/`
- Create: `client/`
- Modify: `README.md`
- Modify: `docs/codebase-summary.md`

## Implementation Steps

1. Initialize backend package with FastAPI, typed settings, logging, and a `/v1/server/health` route.
2. Add `uv` dependency management and commands for lint/test/run.
3. Add config model for database URL, storage root, CORS origins, JWT secret, model pack, threshold, and probe retention.
4. Initialize Flutter app under `client/` with mobile and web targets.
5. Add a minimal API client abstraction in Flutter; no real screens beyond app shell.
6. Add root README quick-start placeholders for backend, client, and database setup.
7. Update docs to mark foundation as in progress only after implementation begins.

## Todo List

- [x] Backend project shell created.
- [x] Flutter shell created.
- [x] Health endpoint returns stable JSON.
- [x] Config and logging are centralized.
- [x] Developer commands documented with `uv`.

## Success Criteria

- [x] `backend` can start a FastAPI app locally through the backend setup guide.
- [x] `client` can run Flutter tests for the app shell.
- [x] Config loads from local environment without committing secrets.
- [x] Health endpoint works without database/model dependencies.
- [x] README accurately states what is implemented vs planned and uses `uv` commands.

## Risk Assessment

- Risk: dependency churn before core behavior exists. Mitigation: pin minimal dependencies and defer optional packages.
- Risk: invalid Python filenames if kebab-case applied literally. Mitigation: confirm importable Python modules use valid module naming.

## Security Considerations

- Do not commit `.env` or secrets.
- Create separate dev secrets guidance.
- Default CORS to explicit local origins, not wildcard.

## Next Steps

Phase 2 can add database foundation. Phase 5 can start client UI shell after API client shape exists.
