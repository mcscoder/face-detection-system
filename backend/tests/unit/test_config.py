from app.core.config import Settings


def test_default_model_pack_is_buffalo_l():
    assert Settings(_env_file=None).model_pack == "buffalo_l"


def test_default_model_provider_is_auto():
    assert Settings(_env_file=None).model_provider == "auto"
