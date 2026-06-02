import hashlib
import hmac
import secrets

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.api.dependencies import local_storage, model_loader, repositories, system_config
from app.core.config import Settings, get_settings
from app.schemas.recognition import Decision, FaceTemplateResponse
from app.schemas.validators import string_id
from app.services.enrollment.service import EnrollmentService
from app.services.recognition.service import RecognitionService
from app.services.recognition.upload_validator import validate_image_upload

router = APIRouter()
PUBLIC_ENROLLMENT_KEY_HASH = "public_enrollment_key_hash"


class PublicPersonCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    display_name: str = Field(min_length=1, max_length=160)


class PublicPersonCreated(BaseModel):
    id: str
    display_name: str
    access_status: str
    enrollment_key: str

    _string_ids = field_validator("id", mode="before")(string_id)


class PublicRecognitionResponse(BaseModel):
    event_id: str
    matched: bool
    decision: Decision
    threshold: float
    failure_reason: str | None = None

    _string_ids = field_validator("event_id", mode="before")(string_id)


@router.post(
    "/people",
    response_model=PublicPersonCreated,
    status_code=status.HTTP_201_CREATED,
)
def create_user_person(payload: PublicPersonCreate, repos=Depends(repositories)):
    enrollment_key = secrets.token_urlsafe(24)
    person = repos["people"].create(
        {
            "display_name": payload.display_name,
            "extra_data": {
                PUBLIC_ENROLLMENT_KEY_HASH: _enrollment_key_hash(enrollment_key),
            },
        }
    )
    return {**person, "enrollment_key": enrollment_key}


@router.post("/faces/{person_id}/samples", response_model=FaceTemplateResponse)
async def upload_user_sample(
    person_id: str,
    enrollment_key: str | None = Form(None),
    expected_pose: str | None = Form(None),
    file: UploadFile = File(...),
    repos=Depends(repositories),
    model=Depends(model_loader),
    storage=Depends(local_storage),
    settings: Settings = Depends(get_settings),
):
    _verify_public_enrollment_key(repos["people"], person_id, enrollment_key)
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
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="MODEL_UNAVAILABLE",
        ) from exc


@router.post("/recognitions/identify", response_model=PublicRecognitionResponse)
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
        response = service.identify(content, device_id, _image_extension(file.content_type))
        return _public_recognition_response(response)
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
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="MODEL_UNAVAILABLE",
        ) from exc


def _image_extension(content_type: str | None) -> str:
    return "png" if content_type == "image/png" else "jpg"


def _enrollment_key_hash(enrollment_key: str) -> str:
    return hashlib.sha256(enrollment_key.encode("utf-8")).hexdigest()


def _verify_public_enrollment_key(people, person_id: str, enrollment_key: str | None) -> None:
    if not enrollment_key:
        raise HTTPException(status.HTTP_403_FORBIDDEN, detail="INVALID_ENROLLMENT_KEY")
    person = people.get(person_id)
    if not person:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="NOT_FOUND")
    extra_data = person.get("extra_data") or {}
    expected_hash = extra_data.get(PUBLIC_ENROLLMENT_KEY_HASH)
    if not isinstance(expected_hash, str) or not hmac.compare_digest(
        expected_hash,
        _enrollment_key_hash(enrollment_key),
    ):
        raise HTTPException(status.HTTP_403_FORBIDDEN, detail="INVALID_ENROLLMENT_KEY")


def _public_recognition_response(response: dict) -> dict:
    return {
        "event_id": response["event_id"],
        "matched": response["matched"],
        "decision": response["decision"],
        "threshold": response["threshold"],
        "failure_reason": response.get("failure_reason"),
    }
