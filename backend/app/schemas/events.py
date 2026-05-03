from datetime import datetime

from pydantic import BaseModel


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

