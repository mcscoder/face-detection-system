import hashlib
from pathlib import Path


class LocalStorage:
    def __init__(self, root: Path):
        self.root = root

    def save_bytes(self, bucket: str, content: bytes, extension: str) -> str:
        digest = hashlib.sha256(content).hexdigest()
        target_dir = self.root / bucket / digest[:2]
        target_dir.mkdir(parents=True, exist_ok=True)
        target = target_dir / f"{digest}.{extension}"
        target.write_bytes(content)
        return str(target)

