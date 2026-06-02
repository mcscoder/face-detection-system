# Phase 05 Verification And Docs

## Context Links

- Root README: `README.md`
- Client README: `client/README.md`
- Docs: `docs/codebase-summary.md`, `docs/project-roadmap.md`, `docs/project-changelog.md`, `docs/design-guidelines.md`

## Overview

- Priority: high
- Current status: planned
- Verify backend/client behavior and update docs to describe the new client purpose.

## Key Insights

- Docs currently say the client is an operational shell with login, capture, result, people, enrollment, events, settings.
- New purpose has two explicit modes: public user and manager.
- Changelog and roadmap must reflect behavior changes only after code passes verification.

## Requirements

- Backend public route tests pass.
- Existing backend API contract tests pass.
- Flutter tests pass.
- Flutter analyze passes.
- Docs mention public user verify/enroll and manager management.
- Docs mention multi-angle guided enrollment is preserved.

## Architecture

Verification runs backend route tests and Flutter test/analyze commands. Docs are updated after verification so they match actual behavior.

## Related Code Files

- Modify: `README.md`
- Modify: `client/README.md`
- Modify: `docs/codebase-summary.md`
- Modify: `docs/project-roadmap.md`
- Modify: `docs/project-changelog.md`
- Modify: `docs/design-guidelines.md`

## Implementation Steps

- [ ] **Step 1: Run backend public route tests**

Run from `backend/`:

```bash
env UV_CACHE_DIR=/home/mcs/Workspaces/face-detection-system/.uv-cache uv run pytest tests/api/test_user_routes.py
```

Expected: PASS.

- [ ] **Step 2: Run backend API contract tests**

Run from `backend/`:

```bash
env UV_CACHE_DIR=/home/mcs/Workspaces/face-detection-system/.uv-cache uv run pytest tests/api/test_api_contracts.py
```

Expected: PASS.

- [ ] **Step 3: Run Flutter tests**

Run from `client/`:

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 4: Run Flutter analyze**

Run from `client/`:

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Update root README current status**

Modify `README.md` Current Status bullets to include:

```markdown
- Implementation state: FastAPI backend foundation, schema, service contracts, strict prompt-gated enrollment, public user verify/enroll endpoints, and tests added; Flutter client public user verify/enroll mode, manager management mode, live guided enrollment, live identify capture, People detail/edit/remove, and live transport are implemented
```

Modify `README.md` Current client code bullet to include:

```markdown
- Current client code: Flutter shell in [`client/`](./client) with public user verify/enroll, manager People detail/edit/remove, guided camera enrollment, live camera identify capture, and live transport
```

Modify `README.md` What Is Implemented list to include:

```markdown
- Public user API routes for unauthenticated face verify and face enrollment
- Flutter client public user mode with Verify Face and Enroll Face only
- Flutter manager mode with login-gated user management screens
```

- [ ] **Step 6: Update client README current state**

Modify `client/README.md` Current State section to include:

```markdown
- App opens in public user mode with Verify Face and Enroll Face.
- Manager entry opens the existing login-gated management area.
- Public user verify and enroll use live camera capture without client-side authentication.
- Enrollment still uses five required prompt poses: face forward, turn left, turn right, look up/down, and natural look.
```

- [ ] **Step 7: Update docs codebase summary**

Modify `docs/codebase-summary.md` Flutter client implementation bullet to include:

```markdown
- Flutter client implementation: public user verify/enroll mode, manager login mode, Android platform files, demo/live API transports, live camera identify capture, prompt-gated guided camera enrollment, People detail/edit/remove, multipart filename sanitization, and tests present
```

- [ ] **Step 8: Update roadmap**

Modify `docs/project-roadmap.md` Client Foundation current note to include:

```markdown
- Current note: Flutter app shell opens in public user mode, manager mode remains login-gated, Android platform files, operational screens, demo/live API abstraction, public live-camera identify/enroll upload, People detail/edit/remove, prompt-gated guided live-camera enrollment, multipart filename sanitization, and widget/state tests exist; client tests/analyze pass; web platform files and manual target-phone smoke pending
```

Modify Enrollment And Recognition UX current note to include:

```markdown
- Current note: public users can verify and enroll without client-side authentication, managers can create/update/remove people, guided enrollment still requires five backend-gated prompt poses, and target-phone enrollment smoke and full end-to-end audit verification remain pending
```

- [ ] **Step 9: Update changelog**

Add to `docs/project-changelog.md` Unreleased Added:

```markdown
- Public user backend routes for unauthenticated face verify and face enrollment
- Flutter public user mode with Verify Face and Enroll Face entry points
- Flutter manager mode entry that keeps management screens behind login
```

Add to Unreleased Changed:

```markdown
- Updated Flutter startup flow from login-first to user-first with manager login as secondary entry
- Preserved five-prompt guided enrollment while adding public user enrollment
```

- [ ] **Step 10: Update design guidelines**

Modify `docs/design-guidelines.md` Screen Types with:

```markdown
### Public User Home

- Only two primary actions: Verify Face and Enroll Face
- Manager entry is secondary
- Keep layout calm, modern, and touch-first
- Avoid exposing operational controls
```

Modify Admin Screen heading to:

```markdown
### Manager Screen
```

- [ ] **Step 11: Commit docs and verification phase**

```bash
git add README.md client/README.md docs/codebase-summary.md docs/project-roadmap.md docs/project-changelog.md docs/design-guidelines.md
git commit -m "feat: document client user and manager modes"
```

## Success Criteria

- Backend public route tests pass.
- Flutter tests and analyze pass.
- Docs describe the implemented two-mode client.

## Risk Assessment

- Do not document manual target-phone smoke as verified unless it is actually run.

## Security Considerations

- Docs must state manager management remains login-gated.

## Next Steps

- Hand off to execution using subagent-driven or inline execution.

## Unresolved Questions

None.
