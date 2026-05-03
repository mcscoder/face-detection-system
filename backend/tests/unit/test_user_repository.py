import pytest

from app.repositories.users import UserRepository


class MissingRoleCursor:
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback):
        return False

    def execute(self, sql, params=None):
        return None

    def fetchall(self):
        return []


class MissingRoleConnection:
    def cursor(self):
        return MissingRoleCursor()


def test_upsert_with_roles_fails_when_admin_role_is_missing():
    repo = UserRepository(MissingRoleConnection())

    with pytest.raises(RuntimeError, match="Missing roles: admin"):
        repo.upsert_with_roles("admin", "hash", "Admin", ["admin"])
