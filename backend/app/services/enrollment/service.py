from app.services.recognition.model_loader import FaceModelLoader
from app.services.storage.local_storage import LocalStorage


class EnrollmentService:
    def __init__(self, model: FaceModelLoader, templates, storage: LocalStorage):
        self.model = model
        self.templates = templates
        self.storage = storage

    def upload_sample(self, person_id: str, image: bytes, extension: str) -> dict:
        face = self.model.extract_single_face(image)
        source_path = self.storage.save_bytes("enrollment", image, extension)
        return self.templates.create(
            {
                "person_id": person_id,
                "embedding": face.embedding,
                "model_pack": self.model.model_pack,
                "model_version": self.model.model_pack,
                "source_image_path": source_path,
                "quality_score": face.quality_score,
            }
        )

