from datetime import datetime

from pydantic import BaseModel, field_validator

from app.schemas.validators import string_id


class RecognitionEventResponse(BaseModel):
    id: str
    device_id: str | None = None
    person_id: str | None = None
    face_template_id: str | None = None
    matched: bool
    decision: str
    similarity_score: float | None = None
    threshold: float
    failure_reason: str | None = None
    created_at: datetime

    _string_ids = field_validator(
        "id",
        "person_id",
        "face_template_id",
        mode="before",
    )(string_id)
