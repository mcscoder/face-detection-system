import json
from typing import Any


class PeopleRepository:
    def __init__(self, conn: Any):
        self.conn = conn

    def create(self, data: dict[str, Any]) -> dict[str, Any]:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO people (employee_code, display_name, job_title, extra_data)
                VALUES (%s, %s, %s, %s::jsonb)
                RETURNING *
                """,
                (
                    data.get("employee_code"),
                    data["display_name"],
                    data.get("job_title"),
                    json.dumps(data.get("extra_data", {})),
                ),
            )
            return cur.fetchone()

    def list(self, query: str | None = None, limit: int = 50) -> list[dict[str, Any]]:
        params: list[Any] = [limit]
        where = "WHERE is_deleted = false"
        if query:
            where += " AND (display_name ILIKE %s OR employee_code ILIKE %s)"
            params = [f"%{query}%", f"%{query}%", limit]
        with self.conn.cursor() as cur:
            cur.execute(
                f"SELECT * FROM people {where} ORDER BY created_at DESC LIMIT %s",
                params,
            )
            return list(cur.fetchall())

    def get(self, person_id: str) -> dict[str, Any] | None:
        with self.conn.cursor() as cur:
            cur.execute("SELECT * FROM people WHERE id = %s AND is_deleted = false", (person_id,))
            return cur.fetchone()

    def update(self, person_id: str, data: dict[str, Any]) -> dict[str, Any] | None:
        current = self.get(person_id)
        if not current:
            return None
        merged_extra = data.get("extra_data", current["extra_data"])
        with self.conn.cursor() as cur:
            cur.execute(
                """
                UPDATE people
                SET employee_code = COALESCE(%s, employee_code),
                    display_name = COALESCE(%s, display_name),
                    job_title = COALESCE(%s, job_title),
                    access_status = COALESCE(%s, access_status),
                    extra_data = %s::jsonb,
                    updated_at = now()
                WHERE id = %s AND is_deleted = false
                RETURNING *
                """,
                (
                    data.get("employee_code"),
                    data.get("display_name"),
                    data.get("job_title"),
                    data.get("access_status"),
                    json.dumps(merged_extra),
                    person_id,
                ),
            )
            return cur.fetchone()

    def soft_delete(self, person_id: str) -> bool:
        with self.conn.cursor() as cur:
            cur.execute(
                "UPDATE people SET is_deleted = true, updated_at = now() WHERE id = %s",
                (person_id,),
            )
            return cur.rowcount > 0

