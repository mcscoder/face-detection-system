from app.repositories.templates import FaceTemplateRepository


class CountCursor:
    def __init__(self):
        self.sql = ""

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback):
        return False

    def execute(self, sql, params=None):
        self.sql = sql

    def fetchone(self):
        return {"count": 2}


class CountConnection:
    def __init__(self):
        self.cursor_instance = CountCursor()

    def cursor(self):
        return self.cursor_instance


def test_count_active_ignores_templates_for_deleted_people():
    conn = CountConnection()

    count = FaceTemplateRepository(conn).count_active()

    assert count == 2
    assert "JOIN people" in conn.cursor_instance.sql
    assert "p.is_deleted = false" in conn.cursor_instance.sql
