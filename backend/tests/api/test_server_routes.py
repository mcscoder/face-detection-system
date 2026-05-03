from app.api.routes.server import health, info
from app.services.recognition.model_loader import FaceModelLoader


def test_health_route_returns_stable_payload():
    response = health()

    assert response.status == "ok"
    assert response.service == "face-detection-system"


def test_info_route_reports_unloaded_model_without_gpu_dependency():
    response = info(FaceModelLoader("buffalo_m"))

    assert response.model.model_pack == "buffalo_m"
    assert response.model.loaded is False
