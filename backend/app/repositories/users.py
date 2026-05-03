from typing import Any


class UserRepository:
    def __init__(self, conn: Any):
        self.conn = conn

    def find_by_username(self, username: str) -> dict[str, Any] | None:
        with self.conn.cursor() as cur:
            cur.execute(
                """
                SELECT u.id, u.username, u.password_hash, u.display_name, u.is_active,
                       COALESCE(array_agg(r.name) FILTER (WHERE r.name IS NOT NULL), '{}') AS roles
                FROM users u
                LEFT JOIN user_roles ur ON ur.user_id = u.id
                LEFT JOIN roles r ON r.id = ur.role_id
                WHERE u.username = %s
                GROUP BY u.id
                """,
                (username,),
            )
            return cur.fetchone()

