---
title: "Upgrade default InsightFace pack to buffalo_l"
description: "Concise plan to align backend default model-pack strings and verify runtime behavior."
status: pending
priority: P2
effort: 1h
branch: main
tags: [backend, insightface, config]
created: 2026-06-02
---

# Upgrade default InsightFace pack to buffalo_l

## Scope
- Align backend default-bearing strings from `buffalo_m` to `buffalo_l`.
- Verify fresh-install defaults and runtime default loading.
- Do not rewrite tests that use `buffalo_m` as explicit fixture data only.

## Exact target files
- `backend/app/core/config.py:20` — env fallback default for `FACE_MODEL_PACK`.
- `backend/app/db/schema.sql:90-94` — seeded `system_settings.model_pack` for fresh databases.
- `backend/README.md:93-98` — documented `.env` example.
- `backend/tests/integration/test_gpu_smoke.py:14` — test fallback when `FACE_MODEL_PACK` is unset.
- Guardrail only: `backend/tests/unit/test_config.py:4-5` already expects `buffalo_l`.

## Data flow and compatibility
- Runtime config starts from `Settings.model_pack` in `backend/app/core/config.py:20`.
- API config then overlays DB settings via `system_config()` in `backend/app/api/dependencies.py:81-87`.
- DB values come from `SettingsRepository.get_all()` in `backend/app/repositories/settings.py:9-12`.
- Risk: changing `schema.sql` alone does not update existing databases because the seed uses `ON CONFLICT DO NOTHING` in `backend/app/db/schema.sql:90-94`.
- Mitigation: implementation must decide whether existing installs need a one-off SQL update for `system_settings.key='model_pack'`; if not, scope this change to fresh installs and env defaults only.

## Plan
1. Re-verify the four default-bearing files above and update any remaining `buffalo_m` default strings to `buffalo_l`.
2. Leave explicit fixture/model metadata tests unchanged unless they are asserting fallback-default behavior.
3. Verify config default with `backend/tests/unit/test_config.py`.
4. Verify fallback load path with `backend/tests/integration/test_gpu_smoke.py`; skip remains valid unless `FACE_RUN_GPU_SMOKE=1`.
5. If existing DBs must switch defaults, add a separate migration step outside `schema.sql`; otherwise document that only new schemas and unset envs pick up `buffalo_l`.

## Verification command
- Run from `backend/`: `uv run pytest tests/unit/test_config.py tests/integration/test_gpu_smoke.py`

## Success criteria
- All default-bearing backend strings resolve to `buffalo_l`.
- Fresh schema seed stores `model_pack = "buffalo_l"`.
- Unit config test passes.
- GPU smoke test uses `buffalo_l` when `FACE_MODEL_PACK` is unset.
