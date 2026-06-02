from app.services.recognition.model_loader import FaceModelLoader, _repair_nested_model_pack


class FakeFaceAnalysis:
    created = []
    prepared = []

    def __init__(self, name, providers):
        self.name = name
        self.providers = providers
        FakeFaceAnalysis.created.append((name, providers))

    def prepare(self, ctx_id, det_size):
        FakeFaceAnalysis.prepared.append((ctx_id, det_size))


def test_repair_nested_model_pack_moves_onnx_files(tmp_path):
    nested = tmp_path / "models" / "buffalo_l" / "buffalo_l"
    nested.mkdir(parents=True)
    source = nested / "det_2.5g.onnx"
    source.write_bytes(b"model")

    repaired = _repair_nested_model_pack("buffalo_l", root=tmp_path)

    assert repaired is True
    assert not source.exists()
    assert (tmp_path / "models" / "buffalo_l" / "det_2.5g.onnx").read_bytes() == b"model"


def test_repair_nested_model_pack_skips_flat_pack(tmp_path):
    model_dir = tmp_path / "models" / "buffalo_l"
    model_dir.mkdir(parents=True)
    existing = model_dir / "det_2.5g.onnx"
    existing.write_bytes(b"model")

    repaired = _repair_nested_model_pack("buffalo_l", root=tmp_path)

    assert repaired is False
    assert existing.exists()


def test_cpu_model_provider_uses_cpu_execution_provider(monkeypatch):
    FakeFaceAnalysis.created = []
    FakeFaceAnalysis.prepared = []
    monkeypatch.setattr(
        "app.services.recognition.model_loader._import_face_analysis",
        lambda: FakeFaceAnalysis,
    )

    model = FaceModelLoader("buffalo_l", "cpu")
    model.load()

    assert FakeFaceAnalysis.created == [("buffalo_l", ["CPUExecutionProvider"])]
    assert FakeFaceAnalysis.prepared == [(-1, (640, 640))]
    assert model.status().providers == ["CPUExecutionProvider"]
