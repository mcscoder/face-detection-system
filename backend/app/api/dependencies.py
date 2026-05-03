from collections.abc import Callable
from pathlib import Path

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.auth.roles import Role, has_role
from app.auth.security import decode_access_token
from app.core.config import Settings, get_settings
from app.db.session import get_connection
from app.db.session import open_connection
from app.repositories.events import RecognitionEventRepository
from app.repositories.people import PeopleRepository
from app.repositories.settings import SettingsRepository
from app.repositories.templates import FaceTemplateRepository
from app.schemas.auth import CurrentUser
from app.services.recognition.model_loader import FaceModelLoader
from app.services.storage.local_storage import LocalStorage

bearer = HTTPBearer(auto_error=False)
_model_loader: FaceModelLoader | None = None


def current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
    settings: Settings = Depends(get_settings),
) -> CurrentUser:
    if credentials is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="UNAUTHORIZED")
    try:
        payload = decode_access_token(credentials.credentials, settings.jwt_secret)
    except ValueError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="UNAUTHORIZED") from None
    return _user_from_payload(payload)


def optional_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
    settings: Settings = Depends(get_settings),
) -> CurrentUser | None:
    if credentials is None:
        return None
    try:
        payload = decode_access_token(credentials.credentials, settings.jwt_secret)
        return _user_from_payload(payload)
    except ValueError:
        return None


def _user_from_payload(payload: dict) -> CurrentUser:
    return CurrentUser(
        id=payload["sub"],
        username=payload["sub"],
        display_name=payload["sub"],
        roles=list(payload.get("roles", [])),
    )


def require_role(role: Role) -> Callable:
    def dependency(user: CurrentUser = Depends(current_user)) -> CurrentUser:
        if not has_role(set(user.roles), role):
            raise HTTPException(status.HTTP_403_FORBIDDEN, detail="FORBIDDEN")
        return user

    return dependency


def repositories(conn=Depends(get_connection)) -> dict:
    return {
        "people": PeopleRepository(conn),
        "templates": FaceTemplateRepository(conn),
        "events": RecognitionEventRepository(conn),
        "settings": SettingsRepository(conn),
    }


def system_config(
    settings: Settings = Depends(get_settings),
    repos=Depends(repositories),
) -> dict:
    values = {
        "recognition_threshold": settings.recognition_threshold,
        "probe_retention_days": settings.probe_retention_days,
        "model_pack": settings.model_pack,
    }
    try:
        values.update(repos["settings"].get_all())
    except RuntimeError:
        pass
    return values


def model_loader(settings: Settings = Depends(get_settings)) -> FaceModelLoader:
    global _model_loader
    if _model_loader is None or _model_loader.model_pack != settings.model_pack:
        _model_loader = FaceModelLoader(settings.model_pack)
    return _model_loader


def local_storage(settings: Settings = Depends(get_settings)) -> LocalStorage:
    return LocalStorage(Path(settings.storage_root))


def active_template_count(
    user: CurrentUser | None = Depends(optional_current_user),
) -> int | None:
    if user is None or not has_role(set(user.roles), Role.OPERATOR):
        return None
    try:
        with open_connection() as conn:
            return FaceTemplateRepository(conn).count_active()
    except Exception:
        return None
