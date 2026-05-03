from app.services.recognition.decision import decide_match
from app.services.recognition.model_loader import FaceModelLoader
from app.services.storage.local_storage import LocalStorage


class RecognitionService:
    def __init__(
        self,
        model: FaceModelLoader,
        templates,
        events,
        storage: LocalStorage,
        threshold: float,
        save_probe: bool,
    ):
        self.model = model
        self.templates = templates
        self.events = events
        self.storage = storage
        self.threshold = threshold
        self.save_probe = save_probe

    def identify(self, image: bytes, device_id: str | None, extension: str) -> dict:
        probe_path = self.storage.save_bytes("probes", image, extension) if self.save_probe else None
        try:
            face = self.model.extract_single_face(image)
            nearest = self.templates.find_nearest(face.embedding, limit=1)
            best = nearest[0] if nearest else None
            score = best["similarity_score"] if best else None
            decision = decide_match(score, self.threshold)
            event = self.events.append(_event(device_id, best, decision, self.threshold, probe_path))
            return _response(event, best, decision, score, self.threshold)
        except ValueError as exc:
            reason = str(exc)
            event = self.events.append(
                {
                    "device_id": device_id,
                    "matched": False,
                    "decision": "DENY",
                    "threshold": self.threshold,
                    "failure_reason": reason,
                    "probe_image_path": probe_path,
                }
            )
            return _response(event, None, None, None, self.threshold, reason)


def _event(device_id: str | None, best: dict | None, decision, threshold: float, probe_path: str | None) -> dict:
    return {
        "device_id": device_id,
        "person_id": best["person_id"] if decision.matched and best else None,
        "face_template_id": best["face_template_id"] if decision.matched and best else None,
        "matched": decision.matched,
        "decision": decision.decision,
        "similarity_score": best["similarity_score"] if best else None,
        "threshold": threshold,
        "failure_reason": decision.failure_reason,
        "probe_image_path": probe_path,
    }


def _response(event, best, decision, score, threshold, reason: str | None = None) -> dict:
    matched = bool(decision and decision.matched)
    return {
        "event_id": str(event["id"]),
        "matched": matched,
        "decision": decision.decision if decision else "DENY",
        "person_id": str(best["person_id"]) if matched else None,
        "face_template_id": str(best["face_template_id"]) if matched else None,
        "similarity_score": score,
        "threshold": threshold,
        "failure_reason": reason or (decision.failure_reason if decision else None),
        "person_summary": _person_summary(best) if matched else None,
    }


def _person_summary(best: dict) -> dict:
    return {
        "id": str(best["person_id"]),
        "display_name": best["display_name"],
        "job_title": best.get("job_title"),
        "access_status": best["access_status"],
    }

