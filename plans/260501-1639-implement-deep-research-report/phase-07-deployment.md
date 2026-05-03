---
phase: 7
title: "Deployment"
status: in-progress
priority: P2
effort: "3d"
dependencies: [6]
---

# Phase 7: Deployment

## Context Links

- [`docs/deployment-guide.md`](../../docs/deployment-guide.md)
- [`docs/project-roadmap.md`](../../docs/project-roadmap.md)
- [`deep-research-report.md`](../../deep-research-report.md)

## Overview

Package the local-first demo for one NVIDIA GPU machine: direct setup commands, runtime commands, backup/restore, model preload verification, and optional HTTPS path for Flutter web camera use.

## Key Insights

- Deployment is local only for v1.
- Mobile over LAN is primary demo path.
- Web over LAN IP needs HTTPS local; localhost web is simpler.

## Requirements

- Functional: local setup, database init, backend run, client run/build, backup, restore, health/info verification.
- Non-functional: repeatable commands, clear GPU fallback warning, no cloud dependency after setup.

## Architecture

Runtime layout:

| Runtime piece | Location |
|---|---|
| API server | local host with GPU |
| PostgreSQL | same host |
| File storage | local disk path from config |
| Flutter mobile | device on LAN |
| Flutter web | localhost or HTTPS local |

## Related Code Files

- Modify: `docs/deployment-guide.md`
- Modify: `docs/project-roadmap.md`
- Modify: `docs/project-changelog.md`
- Modify: `README.md`

## Implementation Steps

1. Document backend environment and dependency install commands using `uv`.
2. Document database schema command with pgvector prerequisite.
3. Add server run command that preloads model and exposes health/info endpoints.
4. Add backup and restore commands for PostgreSQL and storage directory.
5. Add optional HTTPS local notes for web camera demo over LAN.
6. Document current client setup, test, analysis, run, and Android build commands; keep web run/build pending until web platform files exist.
7. Add operational checklist: GPU provider, active template count, threshold, retention, event logging.
8. Update docs and changelog to reflect implemented behavior.

## Todo List

- [x] Setup commands documented.
- [x] Database schema setup verified.
- [x] Backup/restore commands documented.
- [x] Server info verifies model/GPU status.
- [x] Mobile LAN demo path documented.
- [x] Web HTTPS local path documented or implemented.
- [x] Docs synced to actual implementation.

## Success Criteria

  - [x] Fresh local setup can start server and database.
  - [x] `/v1/server/info` reports model pack, providers, active template count, and version info.
  - [ ] Backup and restore preserve people, templates, events, and storage artifacts.
  - [ ] Demo checklist proves enrollment -> identify -> audit event.
  - [x] Docs no longer claim unimplemented features are complete.

## Risk Assessment

- Risk: CUDA/ONNX Runtime compatibility differs by host. Mitigation: document exact tested matrix after implementation and expose CPU fallback warning.
- Risk: HTTPS local setup distracts from primary mobile demo. Mitigation: keep web LAN HTTPS optional unless demo requires it.

## Security Considerations

- Backup artifacts contain sensitive biometric data; document restricted storage.
- Do not include secrets in commands or docs.
- Retention cleanup must avoid deleting enrollment assets incorrectly.

## Next Steps

After deployment phase, run final code review, update roadmap status, and prepare focused commit(s) if repository becomes git-backed.
