from pydantic import BaseModel


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    roles: list[str]
    display_name: str


class CurrentUser(BaseModel):
    id: str
    username: str
    display_name: str
    roles: list[str]

