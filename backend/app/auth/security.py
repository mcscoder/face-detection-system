import base64
import hashlib
import hmac
import json
import os
import time
from typing import Any


def hash_password(
    password: str,
    *,
    iterations: int = 210_000,
    salt: bytes | None = None,
) -> str:
    salt = salt or os.urandom(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, iterations)
    return "pbkdf2_sha256${}${}${}".format(
        iterations,
        base64.b64encode(salt).decode(),
        base64.b64encode(digest).decode(),
    )


def verify_password(password: str, encoded: str) -> bool:
    algorithm, iteration_text, salt_text, digest_text = encoded.split("$", 3)
    if algorithm != "pbkdf2_sha256":
        return False
    salt = base64.b64decode(salt_text)
    expected = base64.b64decode(digest_text)
    actual = hashlib.pbkdf2_hmac(
        "sha256", password.encode(), salt, int(iteration_text)
    )
    return hmac.compare_digest(actual, expected)


def create_access_token(
    subject: str,
    roles: list[str],
    secret: str,
    expires_seconds: int,
) -> str:
    now = int(time.time())
    payload = {"sub": subject, "roles": roles, "iat": now, "exp": now + expires_seconds}
    header = {"alg": "HS256", "typ": "JWT"}
    signing_input = ".".join([_b64_json(header), _b64_json(payload)])
    signature = _sign(signing_input, secret)
    return f"{signing_input}.{signature}"


def decode_access_token(token: str, secret: str) -> dict[str, Any]:
    header_text, payload_text, signature = token.split(".", 2)
    signing_input = f"{header_text}.{payload_text}"
    if not hmac.compare_digest(signature, _sign(signing_input, secret)):
        raise ValueError("invalid token signature")
    payload = json.loads(_b64_decode(payload_text))
    if int(payload["exp"]) < int(time.time()):
        raise ValueError("token expired")
    return payload


def _b64_json(data: dict[str, Any]) -> str:
    return _b64_encode(json.dumps(data, separators=(",", ":")).encode())


def _b64_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def _b64_decode(data: str) -> bytes:
    return base64.urlsafe_b64decode(data + "=" * (-len(data) % 4))


def _sign(signing_input: str, secret: str) -> str:
    digest = hmac.new(secret.encode(), signing_input.encode(), hashlib.sha256).digest()
    return _b64_encode(digest)
