from dataclasses import dataclass


@dataclass(frozen=True)
class FacePose:
    pitch: float
    yaw: float
    roll: float


@dataclass(frozen=True)
class ExtractedFace:
    embedding: list[float]
    quality_score: float
    pose: FacePose | None = None


@dataclass(frozen=True)
class ModelStatus:
    model_pack: str
    loaded: bool
    providers: list[str]
    embedding_dimensions: int | None = None
    warning: str | None = None
