from app.services.recognition.upload_validator import validate_image_upload


def test_accepts_jpeg_magic_bytes():
    content = b"\xff\xd8\xff" + b"content"
    result = validate_image_upload(content, "image/jpeg", 100)
    assert result.ok is True


def test_rejects_bad_magic_bytes():
    result = validate_image_upload(b"not-image", "image/jpeg", 100)
    assert result.ok is False
    assert result.error_code == "INVALID_IMAGE"


def test_rejects_oversized_upload():
    result = validate_image_upload(b"\x89PNG\r\n\x1a\n" + b"x" * 10, "image/png", 8)
    assert result.ok is False

