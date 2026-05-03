from typing import Any


def string_id(value: Any) -> str | None:
    if value is None:
        return None
    return str(value)
