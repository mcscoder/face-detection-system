import pytest
from fastapi import HTTPException

from app.api.routes.faces import upload_sample
from app.api.routes.recognitions import identify
from app.core.config import Settings
from app.services.recognition.types import ExtractedFace, FacePose


class FailingModel:
    def extract_single_face(self, image):
        raise RuntimeError("model missing")


class FrontFaceModel:
    model_pack = "buffalo_m"

    def extract_single_face(self, image):
        return ExtractedFace(
            embedding=[0.1, 0.2],
            quality_score=0.9,
            pose=FacePose(pitch=0.0, yaw=0.0, roll=0.0),
        )


class EmptyTemplates:
    pass


class Templates:
    def create(self, data):
        return {
            "id": "template-1",
            "model_version": data["model_version"],
            "is_active": True,
            **data,
        }


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


@pytest.mark.anyio
async def test_faces_route_maps_wrong_prompt_pose_to_400():
    with pytest.raises(HTTPException) as exc_info:
        await upload_sample(
            person_id="person-1",
            expected_pose="turn_left",
            file=Upload(),
            repos={"templates": Templates()},
            model=FrontFaceModel(),
            storage=Storage(),
            settings=Settings(),
        )

    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "WRONG_POSE"
