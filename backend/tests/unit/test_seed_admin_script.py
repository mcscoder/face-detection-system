from pathlib import Path


def test_schema_does_not_seed_default_admin_password():
    schema = Path("app/db/schema.sql").read_text()

    assert "FACE_ADMIN_PASSWORD" not in schema
    assert "pbkdf2_sha256$210000" not in schema

