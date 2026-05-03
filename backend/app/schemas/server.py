from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str


class ModelInfo(BaseModel):
    model_pack: str
    loaded: bool
    providers: list[str]
    embedding_dimensions: int | None = None
    warning: str | None = None


class ServerInfo(BaseModel):
    service: str
    version: str
    model: ModelInfo

