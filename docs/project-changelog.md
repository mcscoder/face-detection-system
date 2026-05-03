# Project Changelog

## Unreleased

### Added

- Backend FastAPI scaffold managed with `uv`
- Backend `uv.lock` and `.python-version`
- Health and server info API routes
- Auth/RBAC helpers and local JWT/password utilities
- PostgreSQL + pgvector schema file
- Repository layer for users, people, templates, events, and settings
- Recognition upload validation, decision logic, model loader boundary, enrollment and identify services
- Backend unit/API tests for deterministic behavior
- Flutter client shell with login, capture, result, people, enrollment, events, and settings screens
- Client API abstraction aligned to current backend v1 route contracts
- Client widget/state tests for result mapping and controller state
- Initial documentation set for the repository
- README with current status, target stack, quick-start status, and docs map
- Project overview and PDR
- Codebase summary
- Code standards
- System architecture
- Project roadmap
- Deployment guide
- Design guidelines

### Changed

- Validated setup documentation against official PostgreSQL, pgvector, uv, pytest, Uvicorn, Flutter, Dart, and systemctl references
- Removed extra database setup tooling files and documented direct schema setup through `psql`
- Removed duplicated setup links from deployment docs
- Removed undocumented client web run command until platform run folders exist
- Fixed backend health response example to include `version`
- Updated active implementation plan to require `uv` for Python package management
- Updated docs from documentation-only status to backend-foundation-in-progress status
- Replaced documentation-only status with current backend implementation status
- Separated implemented backend surfaces from planned client, GPU, and database verification work
- Made direct PostgreSQL schema application the documented schema setup path
- Expanded backend setup documentation with dependencies, environment, database schema, run, and test steps
- Moved backend setup/run/test commands into the backend README as the single backend setup guide
- Added the client README as the single Flutter client setup/run/test guide
- Removed Flutter client test command from root README

### Removed

- Documentation references to deleted local automation commands

## 2026-05-01

### Added

- Repository documentation initialization
- Repomix snapshot generated for documentation analysis
