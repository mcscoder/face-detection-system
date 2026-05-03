from enum import Enum

from pydantic import BaseModel

from app.schemas.people import PersonSummary


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
