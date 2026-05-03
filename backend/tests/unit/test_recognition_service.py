from app.services.recognition.service import RecognitionService
from app.services.recognition.types import ExtractedFace


class FakeModel:
    def extract_single_face(self, image):
        if image == b"no-face":
            raise ValueError("NO_FACE")
        return ExtractedFace(embedding=[0.1, 0.2], quality_score=0.9)


class FakeTemplates:
    def find_nearest(self, embedding, limit=1):
        return [
            {
                "face_template_id": "template-1",
                "person_id": "person-1",
                "similarity_score": 0.87,
                "display_name": "Local User",
                "job_title": "Operator",
                "access_status": "active",
            }
        ]


class FakeEvents:
    def __init__(self):
        self.rows = []

    def append(self, event):
        row = {"id": f"event-{len(self.rows) + 1}", **event}
        self.rows.append(row)
        return row


class FakeStorage:
    def save_bytes(self, bucket, content, extension):
        return f"{bucket}/sample.{extension}"


def test_identify_allows_high_score_and_writes_event():
    events = FakeEvents()
    service = RecognitionService(
        FakeModel(), FakeTemplates(), events, FakeStorage(), 0.45, save_probe=False
    )

    result = service.identify(b"image", None, "jpg")

    assert result["matched"] is True
    assert result["decision"] == "ALLOW"
    assert result["person_id"] == "person-1"
    assert events.rows[0]["matched"] is True


def test_identify_records_failure_event():
    events = FakeEvents()
    service = RecognitionService(
        FakeModel(), FakeTemplates(), events, FakeStorage(), 0.45, save_probe=False
    )

    result = service.identify(b"no-face", None, "jpg")

    assert result["matched"] is False
    assert result["failure_reason"] == "NO_FACE"
    assert events.rows[0]["failure_reason"] == "NO_FACE"

