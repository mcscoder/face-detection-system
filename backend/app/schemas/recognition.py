from enum import Enum

from pydantic import BaseModel, field_validator

from app.schemas.people import PersonSummary
from app.schemas.validators import string_id


class Decision(str, Enum):
    ALLOW = "ALLOW"
    DENY = "DENY"
    REVIEW = "REVIEW"


class FaceTemplateResponse(BaseModel):
    id: str
    person_id: str
    model_pack: str
    model_version: str
    is_active: bool
    quality_score: float | None = None

    _string_ids = field_validator("id", "person_id", mode="before")(string_id)


class RecognitionResponse(BaseModel):
    event_id: str
    matched: bool
    decision: Decision
    person_id: str | None = None
    face_template_id: str | None = None
    similarity_score: float | None = None
    threshold: float
    failure_reason: str | None = None
    person_summary: PersonSummary | None = None

    _string_ids = field_validator(
        "event_id",
        "person_id",
        "face_template_id",
        mode="before",
    )(string_id)
