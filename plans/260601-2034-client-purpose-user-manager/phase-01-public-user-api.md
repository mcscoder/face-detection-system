# Phase 01 Public User API

## Context Links

- Existing authenticated people routes: `backend/app/api/routes/people.py`
- Existing authenticated face sample route: `backend/app/api/routes/faces.py`
- Existing authenticated identify route: `backend/app/api/routes/recognitions.py`
- Existing API router: `backend/app/api/router.py`
- Existing API tests: `backend/tests/api/test_api_contracts.py`

## Overview

- Priority: high
- Current status: planned
- Add public user endpoints for unauthenticated user verify/enroll while manager endpoints stay protected.

## Key Insights

- Current `/v1/recognitions/identify` requires `operator`.
- Current `/v1/people` create and `/v1/faces/{person_id}/samples` require `enrollment_operator` or `admin`.
- User side has no authentication, so public user endpoints are required for live mode.

## Requirements

- Public user creates own person record through `/v1/user/people`.
- Public user uploads enrollment samples through `/v1/user/faces/{person_id}/samples`.
- Public user verifies through `/v1/user/recognitions/identify`.
- Existing authenticated manager routes keep current RBAC.
- Existing `expected_pose` behavior remains mandatory for enrollment sample upload.

## Architecture

`backend/app/api/routes/user.py` exposes public user routes and reuses existing repositories, storage, model loader, validation, `EnrollmentService`, and `RecognitionService`. It intentionally does not import or depend on `require_role`.

## Related Code Files

- Create: `backend/app/api/routes/user.py`
- Modify: `backend/app/api/router.py`
- Test: `backend/tests/api/test_user_routes.py`

## Implementation Steps

- [ ] **Step 1: Write public user route tests**

Create `backend/tests/api/test_user_routes.py`:

```python
from datetime import datetime
from uuid import uuid4

from fastapi.testclient import TestClient

from app.api.dependencies import repositories, system_config
from app.main import create_app


class FakePeople:
    def create(self, data):
        return {
            "id": uuid4(),
            "display_name": data["display_name"],
            "job_title": data.get("job_title"),
            "access_status": "active",
            "employee_code": data.get("employee_code"),
            "extra_data": data.get("extra_data", {}),
            "created_at": datetime(2026, 1, 1),
            "updated_at": datetime(2026, 1, 1),
        }


class FakeTemplates:
    pass


class FakeEvents:
    pass


class FakeSettings:
    def get_all(self):
        return {}


def _client() -> TestClient:
    app = create_app()
    app.dependency_overrides[repositories] = lambda: {
        "people": FakePeople(),
        "templates": FakeTemplates(),
        "events": FakeEvents(),
        "settings": FakeSettings(),
    }
    app.dependency_overrides[system_config] = lambda: {
        "recognition_threshold": 0.45,
        "probe_retention_days": 0,
        "model_pack": "buffalo_m",
    }
    return TestClient(app)


def test_public_user_create_person_does_not_require_auth():
    response = _client().post("/v1/user/people", json={"display_name": "Bank User"})

    assert response.status_code == 201
    assert isinstance(response.json()["id"], str)
    assert response.json()["display_name"] == "Bank User"


def test_public_user_enrollment_rejects_invalid_image_without_auth():
    response = _client().post(
        "/v1/user/faces/person-1/samples",
        data={"expected_pose": "face_forward"},
        files={"file": ("bad.jpg", b"not-image", "image/jpeg")},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "INVALID_IMAGE"


def test_public_user_identify_rejects_invalid_image_without_auth():
    response = _client().post(
        "/v1/user/recognitions/identify",
        files={"file": ("bad.jpg", b"not-image", "image/jpeg")},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "INVALID_IMAGE"
```

- [ ] **Step 2: Run backend test to verify it fails**

Run from `backend/`:

```bash
env UV_CACHE_DIR=/home/mcs/Workspaces/face-detection-system/.uv-cache uv run pytest tests/api/test_user_routes.py
```

Expected: FAIL with 404 for `/v1/user/people`.

- [ ] **Step 3: Add public user route**

Create `backend/app/api/routes/user.py`:

```python
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status

from app.api.dependencies import local_storage, model_loader, repositories, system_config
from app.core.config import Settings, get_settings
from app.schemas.people import PersonCreate, PersonDetail
from app.schemas.recognition import FaceTemplateResponse, RecognitionResponse
from app.services.enrollment.service import EnrollmentService
from app.services.recognition.service import RecognitionService
from app.services.recognition.upload_validator import validate_image_upload

router = APIRouter()


@router.post("/people", response_model=PersonDetail, status_code=status.HTTP_201_CREATED)
def create_user_person(payload: PersonCreate, repos=Depends(repositories)):
    return repos["people"].create(payload.model_dump())


@router.post("/faces/{person_id}/samples", response_model=FaceTemplateResponse)
async def upload_user_sample(
    person_id: str,
    expected_pose: str | None = Form(None),
    file: UploadFile = File(...),
    repos=Depends(repositories),
    model=Depends(model_loader),
    storage=Depends(local_storage),
    settings: Settings = Depends(get_settings),
):
    content = await file.read()
    result = validate_image_upload(content, file.content_type, settings.max_upload_bytes)
    if not result.ok:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=result.error_code)
    service = EnrollmentService(model, repos["templates"], storage)
    try:
        return service.upload_sample(
            person_id,
            content,
            _image_extension(file.content_type),
            expected_pose,
        )
    except ValueError as exc:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail="MODEL_UNAVAILABLE") from exc


@router.post("/recognitions/identify", response_model=RecognitionResponse)
async def identify_user(
    file: UploadFile = File(...),
    device_id: str | None = None,
    repos=Depends(repositories),
    model=Depends(model_loader),
    storage=Depends(local_storage),
    settings: Settings = Depends(get_settings),
    config=Depends(system_config),
):
    content = await file.read()
    result = validate_image_upload(content, file.content_type, settings.max_upload_bytes)
    if not result.ok:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=result.error_code)
    service = RecognitionService(
        model,
        repos["templates"],
        repos["events"],
        storage,
        float(config["recognition_threshold"]),
        int(config["probe_retention_days"]) > 0,
    )
    try:
        return service.identify(content, device_id, _image_extension(file.content_type))
    except RuntimeError as exc:
        repos["events"].append(
            {
                "device_id": device_id,
                "matched": False,
                "decision": "DENY",
                "threshold": float(config["recognition_threshold"]),
                "failure_reason": "MODEL_UNAVAILABLE",
            }
        )
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail="MODEL_UNAVAILABLE") from exc


def _image_extension(content_type: str | None) -> str:
    return "png" if content_type == "image/png" else "jpg"
```

- [ ] **Step 4: Register public user route**

Modify `backend/app/api/router.py` import:

```python
from app.api.routes import auth, config, events, faces, people, recognitions, server, user
```

Add this include before events:

```python
api_router.include_router(user.router, prefix="/user", tags=["user"])
```

- [ ] **Step 5: Run backend test to verify it passes**

Run from `backend/`:

```bash
env UV_CACHE_DIR=/home/mcs/Workspaces/face-detection-system/.uv-cache uv run pytest tests/api/test_user_routes.py
```

Expected: PASS with 3 tests.

- [ ] **Step 6: Run existing API contract tests**

Run from `backend/`:

```bash
env UV_CACHE_DIR=/home/mcs/Workspaces/face-detection-system/.uv-cache uv run pytest tests/api/test_api_contracts.py
```

Expected: PASS; existing manager/RBAC routes unchanged.

- [ ] **Step 7: Commit phase**

```bash
git add backend/app/api/router.py backend/app/api/routes/user.py backend/tests/api/test_user_routes.py
git commit -m "feat: add public user face endpoints"
```

## Success Criteria

- Public user endpoints return 400 validation errors without auth instead of 401.
- Existing manager endpoints keep current auth failures and role failures.

## Risk Assessment

- Public endpoints duplicate route logic. Keep route bodies small and reuse existing services.
- Public user creation can create people records. This matches the requested no-auth user enrollment model.

## Security Considerations

- Manager endpoints stay protected.
- Public user endpoints still validate uploads before inference.

## Next Steps

- Continue with Phase 02 client API/controller changes.

## Unresolved Questions

None.
