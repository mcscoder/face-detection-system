from pydantic import BaseModel, Field


class SystemConfig(BaseModel):
    recognition_threshold: float = Field(ge=0, le=1)
    probe_retention_days: int = Field(ge=0, le=365)
    model_pack: str


class SystemConfigPatch(BaseModel):
    recognition_threshold: float | None = Field(default=None, ge=0, le=1)
    probe_retention_days: int | None = Field(default=None, ge=0, le=365)

