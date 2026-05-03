import pytest
from fastapi import HTTPException

from app.api.routes.recognitions import identify
from app.core.config import Settings


class FailingModel:
    def extract_single_face(self, image):
        raise RuntimeError("model missing")


class EmptyTemplates:
    pass


class Events:
    def __init__(self):
        self.rows = []

    def append(self, event):
        self.rows.append(event)
        return {"id": "event-1", **event}


class Storage:
    def save_bytes(self, bucket, content, extension):
        return f"{bucket}/sample.{extension}"


class Upload:
    content_type = "image/jpeg"

    async def read(self):
        return b"\xff\xd8\xffimage"


@pytest.mark.anyio
async def test_recognition_route_maps_model_runtime_error_to_503():
    events = Events()

    with pytest.raises(HTTPException) as exc_info:
        await identify(
            file=Upload(),
            repos={"templates": EmptyTemplates(), "events": events},
            model=FailingModel(),
            storage=Storage(),
            settings=Settings(),
            config={"recognition_threshold": 0.45, "probe_retention_days": 0},
        )

    assert exc_info.value.status_code == 503
    assert exc_info.value.detail == "MODEL_UNAVAILABLE"
    assert events.rows[0]["failure_reason"] == "MODEL_UNAVAILABLE"

