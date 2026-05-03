from collections.abc import Generator
from contextlib import contextmanager
from typing import Any

from app.core.config import get_settings


@contextmanager
def open_connection() -> Generator[Any, None, None]:
    try:
        import psycopg
        from psycopg.rows import dict_row
    except ImportError as exc:
        raise RuntimeError("Install backend dependencies before database use.") from exc

    conn = psycopg.connect(get_settings().database_url, row_factory=dict_row)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def get_connection() -> Generator[Any, None, None]:
    with open_connection() as conn:
        yield conn

