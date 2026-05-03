from typing import Any


class FaceTemplateRepository:
    def __init__(self, conn: Any):
        self.conn = conn

    def create(self, data: dict[str, Any]) -> dict[str, Any]:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO face_templates
                  (person_id, embedding, model_pack, model_version, source_image_path, quality_score)
                VALUES (%s, %s::vector, %s, %s, %s, %s)
                RETURNING *
                """,
                (
                    data["person_id"],
                    _vector_literal(data["embedding"]),
                    data["model_pack"],
                    data["model_version"],
                    data.get("source_image_path"),
                    data.get("quality_score"),
                ),
            )
            return cur.fetchone()

    def list_for_person(self, person_id: str) -> list[dict[str, Any]]:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, person_id, model_pack, model_version, source_image_path,
                       is_active, quality_score, created_at
                FROM face_templates
                WHERE person_id = %s
                ORDER BY created_at DESC
                """,
                (person_id,),
            )
            return list(cur.fetchall())

    def disable(self, template_id: str) -> bool:
        with self.conn.cursor() as cur:
            cur.execute(
                "UPDATE face_templates SET is_active = false WHERE id = %s",
                (template_id,),
            )
            return cur.rowcount > 0

    def count_active(self) -> int:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                SELECT count(*) AS count
                FROM face_templates ft
                JOIN people p ON p.id = ft.person_id
                WHERE ft.is_active = true AND p.is_deleted = false
                """
            )
            return int(cur.fetchone()["count"])

    def find_nearest(self, embedding: list[float], limit: int = 1) -> list[dict[str, Any]]:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                SELECT ft.id AS face_template_id, ft.person_id,
                       1 - (ft.embedding <=> %s::vector) AS similarity_score,
                       p.display_name, p.job_title, p.access_status
                FROM face_templates ft
                JOIN people p ON p.id = ft.person_id
                WHERE ft.is_active = true AND p.is_deleted = false
                ORDER BY ft.embedding <=> %s::vector
                LIMIT %s
                """,
                (_vector_literal(embedding), _vector_literal(embedding), limit),
            )
            return list(cur.fetchall())


def _vector_literal(values: list[float]) -> str:
    return "[" + ",".join(f"{value:.8f}" for value in values) + "]"
