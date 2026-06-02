import os
from pathlib import Path
from uuid import uuid4

import pytest

from app.repositories.events import RecognitionEventRepository
from app.repositories.people import PeopleRepository
from app.repositories.templates import FaceTemplateRepository
from app.repositories.users import UserRepository

pytestmark = pytest.mark.database


def test_database_schema_repository_paths():
    database_url = os.environ.get("FACE_TEST_DATABASE_URL")
    if not database_url:
        pytest.skip("FACE_TEST_DATABASE_URL is not set.")

    try:
        import psycopg
        from psycopg.rows import dict_row
    except ImportError as exc:
        pytest.skip(f"psycopg unavailable: {exc}")

    unique = uuid4().hex
    with psycopg.connect(database_url, row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            cur.execute(Path("app/db/schema.sql").read_text())
        people = PeopleRepository(conn)
        templates = FaceTemplateRepository(conn)
        events = RecognitionEventRepository(conn)
        users = UserRepository(conn)

        person = people.create(
            {
                "employee_code": f"test-{unique}",
                "display_name": "Integration User",
                "job_title": "Tester",
                "extra_data": {"department": "security", "test_id": unique},
            }
        )
        template = templates.create(
            {
                "person_id": person["id"],
                "embedding": [0.0] * 512,
                "model_pack": "buffalo_l",
                "model_version": "buffalo_l",
                "quality_score": 0.9,
            }
        )
        event = events.append(
            {
                "person_id": person["id"],
                "face_template_id": template["id"],
                "matched": True,
                "decision": "ALLOW",
                "similarity_score": 1.0,
                "threshold": 0.45,
            }
        )
        admin = users.upsert_with_roles(
            f"admin-{unique}",
            "pbkdf2_sha256$1$c2FsdA==$digest",
            "Integration Admin",
            ["admin"],
        )

        matches = people.list(metadata_key="test_id", metadata_value=unique)
        nearest = templates.find_nearest([0.0] * 512)
        stored_events = events.list(person_id=str(person["id"]))
        stored_admin = users.find_by_username(admin["username"])

        assert matches[0]["id"] == person["id"]
        assert templates.count_active() >= 1
        assert nearest[0]["person_id"] == person["id"]
        assert stored_events[0]["id"] == event["id"]
        assert "admin" in stored_admin["roles"]
