from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status

from app.api.dependencies import local_storage, model_loader, repositories, require_role
from app.auth.roles import Role
from app.core.config import Settings, get_settings
from app.schemas.recognition import FaceTemplateResponse
from app.services.enrollment.service import EnrollmentService
from app.services.recognition.upload_validator import validate_image_upload

router = APIRouter()


@router.post("/{person_id}/samples", response_model=FaceTemplateResponse)
async def upload_sample(
    person_id: str,
    expected_pose: str | None = Form(None),
    file: UploadFile = File(...),
    repos=Depends(repositories),
    model=Depends(model_loader),
    storage=Depends(local_storage),
    settings: Settings = Depends(get_settings),
    _=Depends(require_role(Role.ENROLLMENT)),
):
    content = await file.read()
    result = validate_image_upload(content, file.content_type, settings.max_upload_bytes)
    if not result.ok:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=result.error_code)
    extension = "png" if file.content_type == "image/png" else "jpg"
    service = EnrollmentService(model, repos["templates"], storage)
    try:
        return service.upload_sample(person_id, content, extension, expected_pose)
    except ValueError as exc:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail="MODEL_UNAVAILABLE") from exc


@router.get("/{person_id}", response_model=list[FaceTemplateResponse])
def list_templates(person_id: str, repos=Depends(repositories), _=Depends(require_role(Role.ENROLLMENT))):
    return repos["templates"].list_for_person(person_id)


@router.delete("/{template_id}", status_code=status.HTTP_204_NO_CONTENT)
def disable_template(template_id: str, repos=Depends(repositories), _=Depends(require_role(Role.ADMIN))):
    if not repos["templates"].disable(template_id):
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="NOT_FOUND")
