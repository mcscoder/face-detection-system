from fastapi import APIRouter, Depends

from app import __version__
from app.api.dependencies import model_loader
from app.schemas.server import HealthResponse, ModelInfo, ServerInfo
from app.services.recognition.model_loader import FaceModelLoader

router = APIRouter()


@router.get("/server/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok", service="face-detection-system", version=__version__)


@router.get("/server/info", response_model=ServerInfo)
def info(model: FaceModelLoader = Depends(model_loader)) -> ServerInfo:
    status = model.status()
    return ServerInfo(
        service="face-detection-system",
        version=__version__,
        model=ModelInfo(**status.__dict__),
    )

