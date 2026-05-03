from contextlib import contextmanager

import pytest

from app.cli import create_admin


def test_create_admin_requires_password(monkeypatch):
    monkeypatch.delenv("FACE_ADMIN_PASSWORD", raising=False)

    with pytest.raises(SystemExit) as exc_info:
        create_admin.main()

    assert str(exc_info.value) == "FACE_ADMIN_PASSWORD is required."


def test_create_admin_uses_env_password_and_admin_role(monkeypatch, capsys):
    calls = {}

    class FakeRepository:
        def __init__(self, conn):
            self.conn = conn

        def upsert_with_roles(self, username, password_hash, display_name, roles):
            calls["username"] = username
            calls["password_hash"] = password_hash
            calls["display_name"] = display_name
            calls["roles"] = roles
            return {"username": username}

    @contextmanager
    def fake_open_connection():
        yield object()

    monkeypatch.setenv("FACE_ADMIN_PASSWORD", "local-secret")
    monkeypatch.setenv("FACE_ADMIN_USERNAME", "root")
    monkeypatch.setenv("FACE_ADMIN_DISPLAY_NAME", "Root User")
    monkeypatch.setattr(create_admin, "open_connection", fake_open_connection)
    monkeypatch.setattr(create_admin, "UserRepository", FakeRepository)

    create_admin.main()

    assert calls["username"] == "root"
    assert calls["password_hash"].startswith("pbkdf2_sha256$")
    assert calls["display_name"] == "Root User"
    assert calls["roles"] == ["admin"]
    assert "Admin user ready: root" in capsys.readouterr().out
