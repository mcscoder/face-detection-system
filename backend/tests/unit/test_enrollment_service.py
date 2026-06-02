import pytest

from app.services.enrollment.prompt_pose import validate_prompt_pose
from app.services.enrollment.service import EnrollmentService
from app.services.recognition.types import ExtractedFace, FacePose


class FakeModel:
    model_pack = "buffalo_l"

    def extract_single_face(self, image):
        return ExtractedFace(
            embedding=[0.1, 0.2],
            quality_score=0.9,
            pose=FacePose(pitch=0.0, yaw=0.0, roll=0.0),
        )


class TurnedLeftModel:
    model_pack = "buffalo_l"

    def extract_single_face(self, image):
        return ExtractedFace(
            embedding=[0.1, 0.2],
            quality_score=0.9,
            pose=FacePose(pitch=0.0, yaw=18.0, roll=0.0),
        )


class FakeTemplates:
    def __init__(self):
        self.created = None

    def create(self, data):
        self.created = data
        return {"id": "template-1", **data}


class FakeStorage:
    def __init__(self):
        self.saved = False

    def save_bytes(self, bucket, content, extension):
        self.saved = True
        return f"{bucket}/sample.{extension}"


def test_upload_sample_creates_template_with_model_metadata():
    templates = FakeTemplates()
    service = EnrollmentService(FakeModel(), templates, FakeStorage())

    result = service.upload_sample("person-1", b"image", "jpg", "face_forward")

    assert result["id"] == "template-1"
    assert templates.created["person_id"] == "person-1"
    assert templates.created["model_pack"] == "buffalo_l"
    assert templates.created["source_image_path"] == "enrollment/sample.jpg"


def test_upload_sample_accepts_matching_prompt_pose():
    templates = FakeTemplates()
    service = EnrollmentService(TurnedLeftModel(), templates, FakeStorage())

    result = service.upload_sample("person-1", b"image", "jpg", "turn_left")

    assert result["id"] == "template-1"
    assert templates.created["quality_score"] == 0.9


def test_upload_sample_rejects_wrong_prompt_pose_before_storage():
    storage = FakeStorage()
    service = EnrollmentService(FakeModel(), FakeTemplates(), storage)

    try:
        service.upload_sample("person-1", b"image", "jpg", "turn_left")
    except ValueError as exc:
        assert str(exc) == "WRONG_POSE"
    else:
        raise AssertionError("expected WRONG_POSE")

    assert storage.saved is False


def test_upload_sample_requires_prompt_before_storage():
    storage = FakeStorage()
    service = EnrollmentService(FakeModel(), FakeTemplates(), storage)

    with pytest.raises(ValueError, match="INVALID_PROMPT"):
        service.upload_sample("person-1", b"image", "jpg")

    assert storage.saved is False


@pytest.mark.parametrize(
    ("expected_pose", "pose"),
    [
        ("turn_right", FacePose(pitch=0.0, yaw=0.0, roll=0.0)),
        ("turn_right", FacePose(pitch=0.0, yaw=18.0, roll=0.0)),
        ("turn_left", FacePose(pitch=0.0, yaw=0.0, roll=0.0)),
        ("turn_left", FacePose(pitch=0.0, yaw=-18.0, roll=0.0)),
        ("look_up_down", FacePose(pitch=0.0, yaw=0.0, roll=0.0)),
        ("face_forward", FacePose(pitch=0.0, yaw=18.0, roll=0.0)),
    ],
)
def test_prompt_pose_rejects_wrong_direction_and_no_movement(expected_pose, pose):
    with pytest.raises(ValueError, match="WRONG_POSE"):
        validate_prompt_pose(_face(pose), expected_pose)


@pytest.mark.parametrize(
    ("expected_pose", "pose"),
    [
        ("turn_right", FacePose(pitch=0.0, yaw=-18.0, roll=0.0)),
        ("turn_left", FacePose(pitch=0.0, yaw=18.0, roll=0.0)),
        ("look_up_down", FacePose(pitch=14.0, yaw=0.0, roll=0.0)),
        ("face_forward", FacePose(pitch=0.0, yaw=0.0, roll=0.0)),
    ],
)
def test_prompt_pose_accepts_matching_pose(expected_pose, pose):
    validate_prompt_pose(_face(pose), expected_pose)


def test_prompt_pose_rejects_missing_model_pose():
    with pytest.raises(ValueError, match="WRONG_POSE"):
        validate_prompt_pose(_face(None), "turn_right")


def _face(pose):
    return ExtractedFace(embedding=[0.1, 0.2], quality_score=0.9, pose=pose)
