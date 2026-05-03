from app.services.recognition.service import RecognitionService
from app.services.recognition.types import ExtractedFace


class FakeModel:
    def extract_single_face(self, image):
        if image == b"no-face":
            raise ValueError("NO_FACE")
        if image == b"multi-face":
            raise ValueError("MULTIPLE_FACES")
        if image == b"low-quality":
            raise ValueError("LOW_QUALITY")
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


class EmptyTemplates:
    def find_nearest(self, embedding, limit=1):
        return []


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


def test_identify_records_multiple_faces_failure():
    events = FakeEvents()
    service = RecognitionService(
        FakeModel(), FakeTemplates(), events, FakeStorage(), 0.45, save_probe=False
    )

    result = service.identify(b"multi-face", None, "jpg")

    assert result["failure_reason"] == "MULTIPLE_FACES"
    assert events.rows[0]["failure_reason"] == "MULTIPLE_FACES"


def test_identify_records_low_quality_failure():
    events = FakeEvents()
    service = RecognitionService(
        FakeModel(), FakeTemplates(), events, FakeStorage(), 0.45, save_probe=False
    )

    result = service.identify(b"low-quality", None, "jpg")

    assert result["failure_reason"] == "LOW_QUALITY"
    assert events.rows[0]["failure_reason"] == "LOW_QUALITY"


def test_identify_records_low_score_without_template_match():
    events = FakeEvents()
    service = RecognitionService(
        FakeModel(), EmptyTemplates(), events, FakeStorage(), 0.45, save_probe=False
    )

    result = service.identify(b"image", None, "jpg")

    assert result["matched"] is False
    assert result["failure_reason"] == "LOW_SCORE"
    assert events.rows[0]["failure_reason"] == "LOW_SCORE"
