---
phase: 3
title: "Recognition"
status: complete
priority: P1
effort: "4d"
dependencies: [1, 2]
---

# Phase 3: Recognition

## Context Links

- [`deep-research-report.md`](../../deep-research-report.md)
- [`docs/system-architecture.md`](../../docs/system-architecture.md)
- [`docs/deployment-guide.md`](../../docs/deployment-guide.md)

## Overview

Implement the server-side recognition engine: model loading, GPU provider selection, image validation, face count checks, embedding extraction, quality checks, prompt-pose acceptance, similarity scoring, and threshold-based decisions.

## Key Insights

- Client must never perform AI inference.
- Default model candidate is `buffalo_m`, but implementation must expose model metadata.
- GPU is only 8GB; load model once in the main server process.

## Requirements

- Functional: detect one face, reject invalid face counts, extract embeddings, enroll templates, validate enrollment prompt compliance, identify top match, create decision result.
- Non-functional: GPU-first with CPU fallback warning, predictable memory use, stable error codes.

## Architecture

Recognition service API:

```text
EnrollmentService.upload_sample(person_id, image, expected_pose) -> FaceTemplate
RecognitionService.identify(image, device_id, save_probe) -> RecognitionResult
```

Pipeline:

1. Validate upload bytes, size, MIME, and magic bytes.
2. Decode image safely.
3. Detect faces with InsightFace.
4. Reject `NO_FACE`, `MULTIPLE_FACES`, or `LOW_QUALITY`.
5. For enrollment, reject samples that do not match the current prompt target.
6. Extract normalized embedding.
7. Query nearest active templates.
8. Convert distance to similarity.
9. Compare threshold and return `ALLOW`, `DENY`, or `REVIEW`.
10. Persist event through repository.

## Related Code Files

- Create: `backend/app/services/recognition/`
- Create: `backend/app/services/enrollment/`
- Create: `backend/app/services/storage/`
- Create: `backend/app/schemas/recognition.py`
- Create: `backend/tests/unit/`

## Implementation Steps

1. Add image upload validation utility with explicit error codes.
2. Add model loader that initializes InsightFace with CUDA provider then CPU fallback.
3. Add model info object exposing model pack, providers, embedding dimensions, and loaded status.
4. Implement face detection and single-face validation.
5. Implement enrollment template creation and active template persistence.
6. Implement nearest-template matching using repository query.
7. Implement threshold decision logic and person summary shaping.
8. Add optional local storage for enrollment source images and short-lived probe images.
9. Add unit tests with deterministic service boundaries; reserve real model smoke test for environment-enabled test.
10. Add server-side enrollment prompt gates for front, left, right, up/down, and natural prompts.
11. Return operator-safe prompt feedback when the sample has no face, multiple faces, low quality, or wrong pose.

## Todo List

- [x] Upload validator implemented.
- [x] Model loader implemented.
- [x] Enrollment service creates templates.
- [x] Identify service returns stable result shape.
- [x] Event logging path integrated.
- [x] Real GPU smoke test documented.
- [x] Enrollment prompt-pose validation implemented server-side.
- [x] Enrollment sample rejection returns prompt feedback before template creation.

## Success Criteria

- [x] One good enrollment image creates a template; enrollment workflow can enforce 3-5 samples at API/client layer.
- [x] No face, multiple faces, invalid upload, and low score return explicit failure reasons.
- [x] Match result includes `person_id`, `face_template_id`, `similarity_score`, and `threshold`.
- [x] `/v1/server/info` can report providers and model status from this service.
- [x] CPU fallback is visible, not silent.
- [x] Enrollment only accepts a prompted sample when the server validates the expected pose/quality.
- [x] Wrong-pose enrollment samples return an operator-safe rejection reason.

## Risk Assessment

- Risk: model/package install differs by CUDA version. Mitigation: keep dependency matrix documented and add environment smoke command.
- Risk: real image tests become flaky. Mitigation: unit-test service logic with controlled embeddings; isolate real model tests behind opt-in marker.

## Security Considerations

- Treat uploads as untrusted.
- Do not store probe images unless config allows.
- Keep top-K debug output admin-only.

## Next Steps

Phase 4 wires recognition/enrollment services into authenticated FastAPI routes.
