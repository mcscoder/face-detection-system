from typing import Any


class RecognitionEventRepository:
    def __init__(self, conn: Any):
        self.conn = conn

    def append(self, event: dict[str, Any]) -> dict[str, Any]:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO recognition_events
                  (device_id, person_id, face_template_id, matched, decision,
                   similarity_score, threshold, failure_reason, probe_image_path)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING *
                """,
                (
                    event.get("device_id"),
                    event.get("person_id"),
                    event.get("face_template_id"),
                    event["matched"],
                    event["decision"],
                    event.get("similarity_score"),
                    event["threshold"],
                    event.get("failure_reason"),
                    event.get("probe_image_path"),
                ),
            )
            return cur.fetchone()

    def list(self, limit: int = 50, person_id: str | None = None) -> list[dict[str, Any]]:
        params: list[Any] = []
        where = ""
        if person_id:
            where = "WHERE person_id = %s"
            params.append(person_id)
        params.append(limit)
        with self.conn.cursor() as cur:
            cur.execute(
                f"""
                SELECT *
                FROM recognition_events
                {where}
                ORDER BY created_at DESC
                LIMIT %s
                """,
                params,
            )
            return list(cur.fetchall())

