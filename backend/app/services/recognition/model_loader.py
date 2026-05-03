import logging
from typing import Any

from app.services.recognition.types import ExtractedFace, ModelStatus

logger = logging.getLogger(__name__)


class FaceModelLoader:
    def __init__(self, model_pack: str):
        self.model_pack = model_pack
        self._model: Any | None = None
        self._providers: list[str] = []
        self._warning: str | None = None

    def status(self) -> ModelStatus:
        return ModelStatus(
            model_pack=self.model_pack,
            loaded=self._model is not None,
            providers=self._providers,
            embedding_dimensions=512 if self._model is not None else None,
            warning=self._warning,
        )

    def load(self) -> None:
        if self._model is not None:
            return
        try:
            from insightface.app import FaceAnalysis
        except ImportError as exc:
            raise RuntimeError("Install backend gpu extras before loading model.") from exc

        providers = ["CUDAExecutionProvider", "CPUExecutionProvider"]
        try:
            model = FaceAnalysis(name=self.model_pack, providers=providers)
            model.prepare(ctx_id=0, det_size=(640, 640))
            self._providers = providers
        except Exception as exc:
            logger.warning("CUDA model load failed, falling back to CPU: %s", exc)
            model = FaceAnalysis(name=self.model_pack, providers=["CPUExecutionProvider"])
            model.prepare(ctx_id=-1, det_size=(640, 640))
            self._providers = ["CPUExecutionProvider"]
            self._warning = "CUDA unavailable; using CPUExecutionProvider"
        self._model = model

    def extract_single_face(self, image_bytes: bytes) -> ExtractedFace:
        self.load()
        image = _decode_image(image_bytes)
        faces = self._model.get(image)
        if not faces:
            raise ValueError("NO_FACE")
        if len(faces) > 1:
            raise ValueError("MULTIPLE_FACES")
        face = faces[0]
        embedding = [float(value) for value in face.normed_embedding]
        quality_score = _quality_score(face)
        if quality_score < 0.2:
            raise ValueError("LOW_QUALITY")
        return ExtractedFace(embedding=embedding, quality_score=quality_score)


def _decode_image(image_bytes: bytes) -> Any:
    try:
        import cv2
        import numpy as np
    except ImportError as exc:
        raise RuntimeError("Install backend gpu extras before image decoding.") from exc
    raw = np.frombuffer(image_bytes, dtype=np.uint8)
    image = cv2.imdecode(raw, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("INVALID_IMAGE")
    return image


def _quality_score(face: Any) -> float:
    detection_score = float(getattr(face, "det_score", 0.0))
    return max(0.0, min(1.0, detection_score))

