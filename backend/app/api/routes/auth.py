from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from app.auth.security import create_access_token, verify_password
from app.core.config import Settings, get_settings
from app.db.session import get_connection
from app.repositories.users import UserRepository
from app.schemas.auth import TokenResponse

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
def login(
    form: OAuth2PasswordRequestForm = Depends(),
    conn=Depends(get_connection),
    settings: Settings = Depends(get_settings),
) -> TokenResponse:
    user = UserRepository(conn).find_by_username(form.username)
    if not user or not user["is_active"] or not verify_password(form.password, user["password_hash"]):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="UNAUTHORIZED")
    token = create_access_token(
        user["username"],
        list(user["roles"]),
        settings.jwt_secret,
        settings.jwt_expires_seconds,
    )
    return TokenResponse(
        access_token=token,
        roles=list(user["roles"]),
        display_name=user["display_name"],
    )

