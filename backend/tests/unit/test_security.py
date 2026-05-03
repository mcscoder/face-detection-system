from app.auth.security import create_access_token, decode_access_token, hash_password, verify_password


def test_password_hash_round_trip():
    encoded = hash_password("local-secret")
    assert verify_password("local-secret", encoded) is True
    assert verify_password("wrong", encoded) is False


def test_access_token_round_trip():
    token = create_access_token("admin", ["admin"], "secret", 60)
    payload = decode_access_token(token, "secret")
    assert payload["sub"] == "admin"
    assert payload["roles"] == ["admin"]

