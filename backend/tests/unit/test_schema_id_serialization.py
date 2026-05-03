from datetime import datetime
from uuid import uuid4

from app.schemas.events import RecognitionEventResponse
from app.schemas.recognition import FaceTemplateResponse


def test_face_template_response_serializes_uuid_ids():
    template_id = uuid4()
    person_id = uuid4()

    response = FaceTemplateResponse.model_validate(
        {
            "id": template_id,
            "person_id": person_id,
            "model_pack": "buffalo_m",
            "model_version": "buffalo_m",
            "is_active": True,
        }
    )

    assert response.id == str(template_id)
    assert response.person_id == str(person_id)


def test_event_response_serializes_uuid_ids():
    event_id = uuid4()
    person_id = uuid4()
    template_id = uuid4()

    response = RecognitionEventResponse.model_validate(
        {
            "id": event_id,
            "person_id": person_id,
            "face_template_id": template_id,
            "matched": True,
            "decision": "ALLOW",
            "threshold": 0.62,
            "created_at": datetime(2026, 1, 1),
        }
    )

    assert response.id == str(event_id)
    assert response.person_id == str(person_id)
    assert response.face_template_id == str(template_id)
