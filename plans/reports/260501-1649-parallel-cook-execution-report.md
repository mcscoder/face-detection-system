# Parallel Cook Execution Report

## Decision

- `Go` for parallel cook only after Phase 1 closes. Repo is still docs-only, so first pass is new implementation, not conversion work (`README.md:7-11`, `docs/codebase-summary.md:5-12`).
- Treat real InsightFace/GPU tests as `opt-in` in pass 1. The plan already frames hardware smoke as environment-gated while deterministic logic stays non-hardware (`plans/260501-1639-implement-deep-research-report/phase-03-recognition.md:72-95`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:24-27`).

## Recommended Ordering

1. `Phase 1` alone. It owns initial `backend/`, `client/`, and root docs, so concurrent work would collide immediately (`plans/260501-1639-implement-deep-research-report/phase-01-foundation.md:47-53`).
2. After `Phase 1`:
   - Lane A: `Phase 2` database only (`backend/app/db/`, `backend/app/repositories/`) (`plans/260501-1639-implement-deep-research-report/phase-02-database.md:48-53`).
   - Lane B: `Phase 5a` client shell only. This comes from the plan-level strategy that allows "client shell portions" after Phase 1, but not full client integration (`plans/260501-1639-implement-deep-research-report/plan.md:46-48`).
3. `Phase 3` after `Phase 2`. Recognition depends on DB contracts and must keep single-process GPU loading (`plans/260501-1639-implement-deep-research-report/phase-03-recognition.md:7`, `docs/system-architecture.md:74-77`, `deep-research-report.md:64`).
4. `Phase 4` after `Phase 3`. API wiring depends on auth, repositories, and recognition service contracts (`plans/260501-1639-implement-deep-research-report/phase-04-api.md:7`, `plans/260501-1639-implement-deep-research-report/phase-04-api.md:58-65`).
5. `Phase 5b` after `Phase 4`. Full client screens should bind to real API contracts, not guessed ones (`plans/260501-1639-implement-deep-research-report/phase-05-client.md:7`, `plans/260501-1639-implement-deep-research-report/phase-05-client.md:54-62`).
6. `Phase 6` after `Phases 2-5` integrate (`plans/260501-1639-implement-deep-research-report/phase-06-testing.md:7`).
7. `Phase 7` last for setup/docs/recovery packaging (`plans/260501-1639-implement-deep-research-report/phase-07-deployment.md:7`, `plans/260501-1639-implement-deep-research-report/phase-07-deployment.md:47-52`).

## Parallel-Safe Boundaries

- `Phase 2` vs `Phase 5a` is the only clean first-pass parallel split already implied by the plan (`plans/260501-1639-implement-deep-research-report/plan.md:46-48`).
- `Phase 5a` scope must be narrowed to shell/nav/session/API client structure only. Full capture, enrollment, people CRUD, settings, and event screens depend on Phase 4 contracts (`plans/260501-1639-implement-deep-research-report/phase-05-client.md:20`, `plans/260501-1639-implement-deep-research-report/phase-05-client.md:30`, `plans/260501-1639-implement-deep-research-report/phase-05-client.md:54-62`).
- `Phase 3` and `Phase 4` should stay sequential in merge order. Recognition owns the service contract and `/v1/server/info` inputs before API stabilization (`plans/260501-1639-implement-deep-research-report/phase-03-recognition.md:66-73`, `plans/260501-1639-implement-deep-research-report/phase-04-api.md:39-45`).
- `Phase 6` should own only shared validation and smoke layers. Module-local tests are safer when written by the owning implementation phase, otherwise `backend/tests/` and `client/test/` become conflict hotspots (`plans/260501-1639-implement-deep-research-report/phase-06-testing.md:45-50`).

## File Ownership For Dispatch

- `Phase 1`: `backend/` scaffold, `client/` scaffold, `README.md`, `docs/codebase-summary.md` (`plans/260501-1639-implement-deep-research-report/phase-01-foundation.md:49-53`).
- `Phase 2`: `backend/app/db/**`, `backend/app/repositories/**`.
- `Phase 3`: `backend/app/services/recognition/**`, `backend/app/services/enrollment/**`, `backend/app/services/storage/**`, `backend/app/schemas/recognition.py`.
- `Phase 4`: `backend/app/api/**`, `backend/app/auth/**`, `backend/app/schemas/{auth,people,events,config,common}*`. Do not edit `recognition.py`.
- `Phase 5a/5b`: `client/lib/**`, `client/test/**`, `client/integration_test/**`.
- `Phase 6`: `backend/tests/e2e/**`, shared fixtures.
- `Phase 7`: `docs/deployment-guide.md`, `docs/project-roadmap.md`, `docs/project-changelog.md`, `README.md`.

## Main Risks

- `High`: phase dependency mismatch. Plan text allows partial Phase 5 after Phase 1, but Phase 5 metadata blocks on Phase 4. Mitigation: dispatch `Phase 5a` and `Phase 5b` explicitly (`plans/260501-1639-implement-deep-research-report/plan.md:46-48`, `plans/260501-1639-implement-deep-research-report/phase-05-client.md:7`).
- `High`: hardware-coupled tests will stall early work on non-NVIDIA hosts. Mitigation: default suite excludes real model/GPU smoke; run those manually on target host only (`plans/260501-1639-implement-deep-research-report/phase-06-testing.md:25-27`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:58-59`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:74-75`).
- `Medium`: shared `README.md` and test roots invite parallel collisions across Phases 1, 6, and 7. Mitigation: assign path prefixes, keep root-doc sync late (`plans/260501-1639-implement-deep-research-report/phase-01-foundation.md:49-53`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:47-50`, `plans/260501-1639-implement-deep-research-report/phase-07-deployment.md:47-52`).
- `Medium`: demo scope drift toward web-camera HTTPS. Mitigation: keep mobile-over-LAN as primary path; localhost web only in first pass (`deep-research-report.md:243-247`, `docs/system-architecture.md:68-70`, `plans/260501-1639-implement-deep-research-report/phase-07-deployment.md:25-27`).

## Hardware Test Policy

- `Default required`: unit, DB/API integration, deterministic recognition logic, client widget/state tests (`docs/code-standards.md:54-58`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:35-44`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:54-61`).
- `Opt-in/manual`: real InsightFace model load, provider reporting, NVIDIA GPU smoke, camera hardware smoke, end-to-end host demo (`plans/260501-1639-implement-deep-research-report/phase-03-recognition.md:72-73`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:58-60`, `plans/260501-1639-implement-deep-research-report/phase-06-testing.md:74-75`).

## Notes

- Core data flow stays unchanged: client capture/upload -> API validation -> recognition service -> DB/event write -> decision response (`docs/system-architecture.md:29-39`).
- Backward compatibility risk is low because no app code exists yet; schema-change risk starts with the first DB schema only (`README.md:7-11`, `docs/codebase-summary.md:43-45`).
- Rollback is simplest if each phase lands in separate commits and Phase 2 schema setup stays repeatable (`plans/260501-1639-implement-deep-research-report/phase-02-database.md:67`).

## Unresolved Questions

- Should the existing plan be formally split into `Phase 5a` and `Phase 5b`, or is lane-level dispatch enough?
- Should module-local unit tests live with Phases 2-5 ownership, with Phase 6 reserved for shared integration/e2e only?

**Status:** DONE
**Summary:** Reviewed the existing implementation plan, identified the only safe first-pass parallel boundary, narrowed file ownership, and recommended opt-in handling for GPU/InsightFace smoke tests.
**Concerns/Blockers:** Main blocker is plan inconsistency between `plan.md` parallel guidance and `phase-05-client.md` dependency metadata.
