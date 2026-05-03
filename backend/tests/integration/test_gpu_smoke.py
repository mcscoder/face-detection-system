import os

import pytest

from app.services.recognition.model_loader import FaceModelLoader

pytestmark = pytest.mark.gpu


def test_model_load_reports_provider_status():
    if os.environ.get("FACE_RUN_GPU_SMOKE") != "1":
        pytest.skip("FACE_RUN_GPU_SMOKE=1 is not set.")

    model = FaceModelLoader(os.environ.get("FACE_MODEL_PACK", "buffalo_m"))
    model.load()
    status = model.status()

    assert status.loaded is True
    assert status.providers
    assert status.embedding_dimensions == 512
