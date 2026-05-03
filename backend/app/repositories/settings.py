import json
from typing import Any


class SettingsRepository:
    def __init__(self, conn: Any):
        self.conn = conn

    def get_all(self) -> dict[str, Any]:
        with self.conn.cursor() as cur:
            cur.execute("SELECT key, value FROM system_settings ORDER BY key")
            return {row["key"]: row["value"] for row in cur.fetchall()}

    def set(self, key: str, value: Any) -> dict[str, Any]:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO system_settings (key, value, updated_at)
                VALUES (%s, %s::jsonb, now())
                ON CONFLICT (key) DO UPDATE SET value = excluded.value, updated_at = now()
                RETURNING key, value, updated_at
                """,
                (key, json.dumps(value)),
            )
            return cur.fetchone()

