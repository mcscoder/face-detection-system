# Code Standards

## Purpose

Standards for the implementation in this repository.

## Current Constraint

- Application code exists in backend and client folders
- Keep standards aligned with the FastAPI, PostgreSQL, `uv`, and Flutter stack

## File And Module Rules

- Use kebab-case for file names
- Keep code files under 200 lines when practical
- Split services by concern, not by framework default
- Prefer focused modules over large utility blobs

## Backend Standards

- Use `uv` for Python dependency management, virtual environments, and backend command execution
- Use FastAPI with typed request and response models
- Separate API layer, service layer, and storage layer
- Keep recognition logic isolated from HTTP handlers
- Validate uploads before any inference step
- Use explicit error codes and stable response shapes

## Data Standards

- Use PostgreSQL as the single transactional store
- Use `jsonb` for flexible metadata
- Use `pgvector` for embeddings
- Version face templates and model packs
- Soft delete sensitive entities when possible

## API Standards

- Use JSON for metadata endpoints
- Use multipart upload for image ingestion
- Return stable IDs, not only boolean outcomes
- Include `event_id`, `threshold`, and score in recognition responses
- Keep admin-only fields behind authorization checks

## Security Standards

- Treat biometric data as sensitive
- Enforce RBAC for admin and operator actions
- Validate MIME type, size, and content signature for uploads
- Log access-control decisions
- Minimize storage of probe images

## Testing Standards

- Add unit tests for service logic
- Add integration tests for API and database paths
- Add recognition-path tests for edge cases
- Cover no-face, multi-face, and low-score outcomes

## Documentation Standards

- Update docs when behavior changes
- Do not document unimplemented features as finished
- Prefer short, direct prose
- Keep docs synchronized with actual code and current roadmap

## References

- Backend package config: [`../backend/pyproject.toml`](../backend/pyproject.toml)
- Client package config: [`../client/pubspec.yaml`](../client/pubspec.yaml)
- Project rules: [`../AGENTS.md`](../AGENTS.md)
