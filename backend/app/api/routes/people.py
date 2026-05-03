from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies import repositories, require_role
from app.auth.roles import Role
from app.schemas.people import PersonCreate, PersonDetail, PersonUpdate

router = APIRouter()


@router.get("", response_model=list[PersonDetail])
def list_people(query: str | None = None, repos=Depends(repositories), _=Depends(require_role(Role.OPERATOR))):
    return repos["people"].list(query=query)


@router.post("", response_model=PersonDetail, status_code=status.HTTP_201_CREATED)
def create_person(payload: PersonCreate, repos=Depends(repositories), _=Depends(require_role(Role.ENROLLMENT))):
    return repos["people"].create(payload.model_dump())


@router.get("/{person_id}", response_model=PersonDetail)
def get_person(person_id: str, repos=Depends(repositories), _=Depends(require_role(Role.OPERATOR))):
    person = repos["people"].get(person_id)
    if not person:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="NOT_FOUND")
    return person


@router.patch("/{person_id}", response_model=PersonDetail)
def update_person(
    person_id: str,
    payload: PersonUpdate,
    repos=Depends(repositories),
    _=Depends(require_role(Role.ENROLLMENT)),
):
    person = repos["people"].update(person_id, payload.model_dump(exclude_unset=True))
    if not person:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="NOT_FOUND")
    return person


@router.delete("/{person_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_person(person_id: str, repos=Depends(repositories), _=Depends(require_role(Role.ADMIN))):
    if not repos["people"].soft_delete(person_id):
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="NOT_FOUND")

