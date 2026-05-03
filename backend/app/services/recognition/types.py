from dataclasses import dataclass


@dataclass(frozen=True)
class ExtractedFace:
    embedding: list[float]
    quality_score: float


@dataclass(frozen=True)
class ModelStatus:
    model_pack: str
    loaded: bool
    providers: list[str]
    embedding_dimensions: int | None = None
    warning: str | None = None

