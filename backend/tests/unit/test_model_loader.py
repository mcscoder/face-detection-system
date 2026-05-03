from app.services.recognition.model_loader import _repair_nested_model_pack


def test_repair_nested_model_pack_moves_onnx_files(tmp_path):
    nested = tmp_path / "models" / "buffalo_m" / "buffalo_m"
    nested.mkdir(parents=True)
    source = nested / "det_2.5g.onnx"
    source.write_bytes(b"model")

    repaired = _repair_nested_model_pack("buffalo_m", root=tmp_path)

    assert repaired is True
    assert not source.exists()
    assert (tmp_path / "models" / "buffalo_m" / "det_2.5g.onnx").read_bytes() == b"model"


def test_repair_nested_model_pack_skips_flat_pack(tmp_path):
    model_dir = tmp_path / "models" / "buffalo_m"
    model_dir.mkdir(parents=True)
    existing = model_dir / "det_2.5g.onnx"
    existing.write_bytes(b"model")

    repaired = _repair_nested_model_pack("buffalo_m", root=tmp_path)

    assert repaired is False
    assert existing.exists()
