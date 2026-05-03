from fastapi import APIRouter, Depends

from app.api.dependencies import repositories, require_role, system_config
from app.auth.roles import Role
from app.schemas.config import SystemConfig, SystemConfigPatch

router = APIRouter()


@router.get("", response_model=SystemConfig)
def get_config(config=Depends(system_config), _=Depends(require_role(Role.ADMIN))):
    return SystemConfig(
        recognition_threshold=config["recognition_threshold"],
        probe_retention_days=config["probe_retention_days"],
        model_pack=config["model_pack"],
    )


@router.patch("", response_model=dict)
def patch_config(
    payload: SystemConfigPatch,
    repos=Depends(repositories),
    _=Depends(require_role(Role.ADMIN)),
):
    updates = payload.model_dump(exclude_unset=True)
    return {key: repos["settings"].set(key, value) for key, value in updates.items()}
