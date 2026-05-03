from fastapi import APIRouter, Depends

from app.api.dependencies import repositories, require_role
from app.auth.roles import Role
from app.schemas.events import RecognitionEventResponse

router = APIRouter()


@router.get("", response_model=list[RecognitionEventResponse])
def list_events(
    person_id: str | None = None,
    limit: int = 50,
    repos=Depends(repositories),
    _=Depends(require_role(Role.OPERATOR)),
):
    return repos["events"].list(limit=limit, person_id=person_id)

