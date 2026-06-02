from app.core.config import Settings


def test_default_model_pack_is_buffalo_l():
    assert Settings(_env_file=None).model_pack == "buffalo_l"
