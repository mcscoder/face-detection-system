from typing import Any


class UserRepository:
    def __init__(self, conn: Any):
        self.conn = conn

    def upsert_with_roles(
        self,
        username: str,
        password_hash: str,
        display_name: str,
        roles: list[str],
    ) -> dict[str, Any]:
        with self.conn.cursor() as cur:
            cur.execute("SELECT name FROM roles WHERE name = ANY(%s)", (roles,))
            found_roles = {row["name"] for row in cur.fetchall()}
            missing_roles = sorted(set(roles) - found_roles)
            if missing_roles:
                raise RuntimeError(f"Missing roles: {', '.join(missing_roles)}")

            cur.execute(
                """
                INSERT INTO users (username, password_hash, display_name, is_active)
                VALUES (%s, %s, %s, true)
                ON CONFLICT (username) DO UPDATE
                SET password_hash = excluded.password_hash,
                    display_name = excluded.display_name,
                    is_active = true
                RETURNING id, username, display_name, is_active
                """,
                (username, password_hash, display_name),
            )
            user = cur.fetchone()
            cur.execute(
                """
                INSERT INTO user_roles (user_id, role_id)
                SELECT %s, id FROM roles WHERE name = ANY(%s)
                ON CONFLICT DO NOTHING
                """,
                (user["id"], roles),
            )
            cur.execute(
                """
                SELECT count(*) AS count
                FROM user_roles ur
                JOIN roles r ON r.id = ur.role_id
                WHERE ur.user_id = %s AND r.name = ANY(%s)
                """,
                (user["id"], roles),
            )
            if int(cur.fetchone()["count"]) != len(set(roles)):
                raise RuntimeError("Role assignment failed.")
            return user

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
