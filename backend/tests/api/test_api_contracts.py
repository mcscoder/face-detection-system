from datetime import datetime
from uuid import uuid4

from fastapi.testclient import TestClient

from app.api.dependencies import current_user, repositories, system_config
from app.main import create_app
from app.schemas.auth import CurrentUser


class FakePeople:
    def __init__(self):
        self.calls = []

    def list(self, **kwargs):
        self.calls.append(kwargs)
        return [
            {
                "id": "person-1",
                "display_name": "Local User",
                "job_title": None,
                "access_status": "active",
                "extra_data": {"department": "security"},
                "created_at": datetime(2026, 1, 1),
                "updated_at": datetime(2026, 1, 1),
            }
        ]

    def create(self, data):
        return {
            "id": uuid4(),
            "display_name": data["display_name"],
            "job_title": data.get("job_title"),
            "access_status": "active",
            "employee_code": data.get("employee_code"),
            "extra_data": data.get("extra_data", {}),
            "created_at": datetime(2026, 1, 1),
            "updated_at": datetime(2026, 1, 1),
        }


class FakeTemplates:
    def disable(self, template_id):
        return True


def _client(roles: list[str] | None = None, fake_repos: dict | None = None) -> TestClient:
    app = create_app()
    app.dependency_overrides[repositories] = lambda: fake_repos or {
        "people": FakePeople(),
        "templates": FakeTemplates(),
    }
    app.dependency_overrides[system_config] = lambda: {
        "recognition_threshold": 0.45,
        "probe_retention_days": 0,
        "model_pack": "buffalo_m",
    }
    if roles is not None:
        app.dependency_overrides[current_user] = lambda: CurrentUser(
            id="user-1",
            username="operator",
            display_name="Operator",
            roles=roles,
        )
    return TestClient(app)


def test_server_info_without_auth_does_not_report_template_count():
    response = _client().get("/v1/server/info")

    assert response.status_code == 200
    assert response.json()["active_template_count"] is None


def test_people_list_accepts_metadata_filter_and_keeps_detail_contract():
    fake_people = FakePeople()
    client = _client(["operator"], {"people": fake_people, "templates": FakeTemplates()})

    response = client.get("/v1/people?metadata_key=department&metadata_value=security")

    assert response.status_code == 200
    assert response.json()[0]["id"] == "person-1"
    assert response.json()[0]["extra_data"] == {"department": "security"}
    assert fake_people.calls[0]["metadata_key"] == "department"
    assert fake_people.calls[0]["metadata_value"] == "security"


def test_create_person_serializes_database_uuid_id():
    client = _client(["enrollment_operator"])

    response = client.post("/v1/people", json={"display_name": "New User"})

    assert response.status_code == 201
    assert isinstance(response.json()["id"], str)
    assert response.json()["display_name"] == "New User"


def test_config_requires_admin_role():
    response = _client(["operator"]).get("/v1/config")

    assert response.status_code == 403


def test_auth_required_without_token():
    response = _client().get("/v1/config")

    assert response.status_code == 401


def test_operator_cannot_disable_face_template():
    response = _client(["operator"]).delete("/v1/faces/template-1")

    assert response.status_code == 403


def test_identify_rejects_invalid_image_before_inference():
    response = _client(["operator"]).post(
        "/v1/recognitions/identify",
        files={"file": ("bad.jpg", b"not-image", "image/jpeg")},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "INVALID_IMAGE"
