from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

from app.api.dependencies import (
    local_storage,
    model_loader,
    repositories,
    require_role,
    system_config,
)
from app.auth.roles import Role
from app.core.config import Settings, get_settings
from app.schemas.recognition import RecognitionResponse
from app.services.recognition.service import RecognitionService
from app.services.recognition.upload_validator import validate_image_upload

router = APIRouter()


@router.post("/identify", response_model=RecognitionResponse)
async def identify(
    file: UploadFile = File(...),
    device_id: str | None = None,
    repos=Depends(repositories),
    model=Depends(model_loader),
    storage=Depends(local_storage),
    settings: Settings = Depends(get_settings),
    config=Depends(system_config),
    _=Depends(require_role(Role.OPERATOR)),
):
    content = await file.read()
    result = validate_image_upload(content, file.content_type, settings.max_upload_bytes)
    if not result.ok:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=result.error_code)
    extension = "png" if file.content_type == "image/png" else "jpg"
    service = RecognitionService(
        model,
        repos["templates"],
        repos["events"],
        storage,
        float(config["recognition_threshold"]),
        int(config["probe_retention_days"]) > 0,
    )
    try:
        return service.identify(content, device_id, extension)
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
