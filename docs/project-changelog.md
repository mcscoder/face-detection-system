# Project Changelog

## Unreleased

### Added

- Backend FastAPI scaffold managed with `uv`
- Backend `uv.lock` and `.python-version`
- Health and server info API routes
- Auth/RBAC helpers and local JWT/password utilities
- PostgreSQL + pgvector schema file
- Repository layer for users, people, templates, events, and settings
- First admin creation command through `FACE_ADMIN_PASSWORD`
- People list metadata filtering through `metadata_key` and `metadata_value`
- Recognition upload validation, decision logic, model loader boundary, enrollment and identify services
- Server info `active_template_count` field for authenticated admin/operator/enrollment users, excluding deleted people
- Backend unit/API tests for deterministic behavior
- Opt-in database repository smoke test and GPU model smoke test
- Flutter client shell with login, capture, result, people, enrollment, events, and settings screens
- Flutter Android platform files and release APK build path
- Client API abstraction aligned to current backend v1 route contracts
- Live Flutter API transport selected by `client/env/mobile.json`
- Android live-camera identify upload
- Guided live-camera enrollment with five pose prompts, expected-pose upload metadata, server-gated sample acceptance, and retry-in-session handling
- Client person creation and enrollment sample upload through live backend routes
- Client widget/state tests for result mapping and controller state
- Client guided enrollment tests for prompt order, automatic capture completion, backend-gated retry state, and wrong-pose feedback
- Client live identify tests for camera session start, capture, submit, and result state
- Client live transport test for form login, bearer auth, JSON post, and multipart upload
- Client People tab detail, edit/update, and Admin remove flows
- Public user backend routes for unauthenticated face verify and face enrollment
- Flutter public user mode with Verify Face and Enroll Face entry points
- Flutter manager mode entry that keeps management screens behind login
- Backend and Flutter regressions for directional wrong-pose enrollment rejection
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

- Upgraded the default InsightFace model pack from `buffalo_m` to `buffalo_l`
- Fixed API response serialization for database UUID IDs in people, face template, and event responses
- Repaired nested InsightFace model-pack extraction before model startup retry
- Moved InsightFace, ONNX Runtime GPU, OpenCV, and NumPy into normal backend dependencies
- Validated setup documentation against official PostgreSQL, pgvector, uv, pytest, Uvicorn, Flutter, Dart, and systemctl references
- Removed extra database setup tooling files and documented direct schema setup through `psql`
- Removed duplicated setup links from deployment docs
- Removed undocumented client web run command until web platform files exist
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
- Added backup/restore, admin seed, model preload, and GPU smoke commands to setup docs
- Updated setup docs to require `FACE_ADMIN_PASSWORD`, describe auth-gated `active_template_count`, document people metadata filters, and list opt-in database/GPU smoke commands
- Replaced identify image picking with live-camera capture in the mobile client
- Updated Flutter startup flow from login-first to user-first with manager login as secondary entry
- Preserved five-prompt guided enrollment while adding public user enrollment
- Redesigned the Flutter demo UI with fixed public camera verification, real oval face guides, two-step public enrollment, and a rail-based manager console dashboard
- Fixed public enrollment text overflow on short screens
- Added server-side enrollment prompt pose validation for front, left, right, up/down, and natural prompts
- Tightened enrollment prompt pose validation to require prompt metadata and reject no-movement or wrong-direction samples before template creation
- Extended live client transport to cover person detail, update, and delete API methods

### Removed

- Documentation references to deleted local automation commands

## 2026-05-01

### Added

- Repository documentation initialization
- Repomix snapshot generated for documentation analysis
