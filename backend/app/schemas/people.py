from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field, field_validator

from app.schemas.validators import string_id


class PersonCreate(BaseModel):
    employee_code: str | None = None
    display_name: str = Field(min_length=1, max_length=160)
    job_title: str | None = None
    extra_data: dict[str, Any] = Field(default_factory=dict)


class PersonUpdate(BaseModel):
    employee_code: str | None = None
    display_name: str | None = Field(default=None, min_length=1, max_length=160)
    job_title: str | None = None
    access_status: str | None = None
    extra_data: dict[str, Any] | None = None


class PersonSummary(BaseModel):
    id: str
    display_name: str
    job_title: str | None = None
    access_status: str

    _string_ids = field_validator("id", mode="before")(string_id)


class PersonDetail(PersonSummary):
    employee_code: str | None = None
    extra_data: dict[str, Any]
    created_at: datetime
    updated_at: datetime
