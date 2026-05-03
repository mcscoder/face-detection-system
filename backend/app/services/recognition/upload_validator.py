from dataclasses import dataclass


JPEG_MAGIC = b"\xff\xd8\xff"
PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


@dataclass(frozen=True)
class UploadValidationResult:
    ok: bool
    error_code: str | None = None
    content_type: str | None = None


def validate_image_upload(
    content: bytes,
    content_type: str | None,
    max_bytes: int,
) -> UploadValidationResult:
    if not content or len(content) > max_bytes:
        return UploadValidationResult(False, "INVALID_IMAGE", content_type)
    if content_type not in {"image/jpeg", "image/png"}:
        return UploadValidationResult(False, "INVALID_IMAGE", content_type)
    if content.startswith(JPEG_MAGIC) or content.startswith(PNG_MAGIC):
        return UploadValidationResult(True, content_type=content_type)
    return UploadValidationResult(False, "INVALID_IMAGE", content_type)

