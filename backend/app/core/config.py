from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str = Field(
        "postgresql://face:face@localhost:5432/face_detection",
        alias="FACE_DATABASE_URL",
    )
    storage_root: Path = Field(Path("./local-storage"), alias="FACE_STORAGE_ROOT")
    jwt_secret: str = Field("change-me-in-local-env", alias="FACE_JWT_SECRET")
    jwt_expires_seconds: int = Field(3600, alias="FACE_JWT_EXPIRES_SECONDS")
    cors_origins: list[str] = Field(
        ["http://localhost:3000", "http://localhost:5173"],
        alias="FACE_CORS_ORIGINS",
    )
    model_pack: str = Field("buffalo_m", alias="FACE_MODEL_PACK")
    preload_model: bool = Field(False, alias="FACE_PRELOAD_MODEL")
    recognition_threshold: float = Field(0.45, alias="FACE_RECOGNITION_THRESHOLD")
    probe_retention_days: int = Field(0, alias="FACE_PROBE_RETENTION_DAYS")
    max_upload_bytes: int = Field(5_242_880, alias="FACE_MAX_UPLOAD_BYTES")
    log_level: str = Field("INFO", alias="FACE_LOG_LEVEL")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        populate_by_name=True,
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
