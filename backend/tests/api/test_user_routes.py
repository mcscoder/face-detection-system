from datetime import datetime
from uuid import uuid4

from fastapi.testclient import TestClient

from app.api.dependencies import local_storage, model_loader, repositories, system_config
from app.main import create_app
from app.services.recognition.types import ExtractedFace


class FakePeople:
    def __init__(self):
        self.people = {}

    def create(self, data):
        person = {
            "id": uuid4(),
            "display_name": data["display_name"],
            "job_title": data.get("job_title"),
            "access_status": "active",
            "employee_code": data.get("employee_code"),
            "extra_data": data.get("extra_data", {}),
            "created_at": datetime(2026, 1, 1),
            "updated_at": datetime(2026, 1, 1),
        }
        self.people[str(person["id"])] = person
        return person

    def get(self, person_id):
        return self.people.get(person_id)


class FakeTemplates:
    def create(self, data):
        return {
            "id": uuid4(),
            "person_id": data["person_id"],
            "model_pack": data["model_pack"],
            "model_version": data["model_version"],
            "is_active": True,
            "quality_score": data.get("quality_score"),
        }

    def find_nearest(self, embedding, limit=1):
        return [
            {
                "person_id": "person-private",
                "face_template_id": "template-private",
                "similarity_score": 0.99,
                "display_name": "Private Person",
                "job_title": "Owner",
                "access_status": "active",
            }
        ]


class FakeEvents:
    def append(self, data):
        return {"id": "event-private", **data}


class FakeSettings:
    def get_all(self):
        return {}


class FakeModel:
    model_pack = "buffalo_l"

    def extract_single_face(self, image):
        return ExtractedFace(embedding=[0.1, 0.2], quality_score=0.9)


class FakeStorage:
    def save_bytes(self, folder, content, extension):
        return f"{folder}/file.{extension}"


def _client(
    fake_people: FakePeople | None = None,
    fake_model: FakeModel | None = None,
) -> TestClient:
    app = create_app()
    people = fake_people or FakePeople()
    app.dependency_overrides[repositories] = lambda: {
        "people": people,
        "templates": FakeTemplates(),
        "events": FakeEvents(),
        "settings": FakeSettings(),
    }
    app.dependency_overrides[system_config] = lambda: {
        "recognition_threshold": 0.45,
        "probe_retention_days": 0,
        "model_pack": "buffalo_l",
    }
    if fake_model is not None:
        app.dependency_overrides[model_loader] = lambda: fake_model
        app.dependency_overrides[local_storage] = lambda: FakeStorage()
    return TestClient(app)


def test_public_user_create_person_does_not_require_auth():
    response = _client().post(
        "/v1/user/people",
        json={"display_name": "Bank User"},
    )

    assert response.status_code == 201
    assert isinstance(response.json()["id"], str)
    assert response.json()["display_name"] == "Bank User"
    assert isinstance(response.json()["enrollment_key"], str)
    assert "employee_code" not in response.json()
    assert "extra_data" not in response.json()


def test_public_user_create_person_rejects_operational_fields():
    response = _client().post(
        "/v1/user/people",
        json={
            "display_name": "Bank User",
            "employee_code": "EMP-1",
            "job_title": "Manager",
            "extra_data": {"department": "private"},
        },
    )

    assert response.status_code == 422


def test_public_user_enrollment_rejects_invalid_image_without_auth():
    client = _client()
    created = client.post("/v1/user/people", json={"display_name": "Bank User"})

    response = client.post(
        f"/v1/user/faces/{created.json()['id']}/samples",
        data={
            "enrollment_key": created.json()["enrollment_key"],
            "expected_pose": "face_forward",
        },
        files={"file": ("bad.jpg", b"not-image", "image/jpeg")},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "INVALID_IMAGE"


def test_public_user_enrollment_requires_matching_enrollment_key():
    client = _client()
    created = client.post("/v1/user/people", json={"display_name": "Bank User"})

    response = client.post(
        f"/v1/user/faces/{created.json()['id']}/samples",
        data={"enrollment_key": "wrong", "expected_pose": "face_forward"},
        files={"file": ("bad.jpg", b"not-image", "image/jpeg")},
    )

    assert response.status_code == 403
    assert response.json()["detail"] == "INVALID_ENROLLMENT_KEY"


def test_public_user_identify_rejects_invalid_image_without_auth():
    response = _client().post(
        "/v1/user/recognitions/identify",
        files={"file": ("bad.jpg", b"not-image", "image/jpeg")},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "INVALID_IMAGE"


def test_public_user_identify_hides_private_match_identifiers():
    response = _client(fake_model=FakeModel()).post(
        "/v1/user/recognitions/identify",
        files={"file": ("face.jpg", b"\xff\xd8\xffvalid", "image/jpeg")},
    )

    assert response.status_code == 200
    assert response.json()["matched"] is True
    assert response.json()["decision"] == "ALLOW"
    assert "person_id" not in response.json()
    assert "face_template_id" not in response.json()
    assert "person_summary" not in response.json()
