import os

from app.auth.security import hash_password
from app.db.session import open_connection
from app.repositories.users import UserRepository


def main() -> None:
    password = os.environ.get("FACE_ADMIN_PASSWORD")
    if not password:
        raise SystemExit("FACE_ADMIN_PASSWORD is required.")

    username = os.environ.get("FACE_ADMIN_USERNAME", "admin")
    display_name = os.environ.get("FACE_ADMIN_DISPLAY_NAME", "Local Admin")
    password_hash = hash_password(password)

    with open_connection() as conn:
        user = UserRepository(conn).upsert_with_roles(
            username,
            password_hash,
            display_name,
            ["admin"],
        )

    print(f"Admin user ready: {user['username']}")


if __name__ == "__main__":
    main()
