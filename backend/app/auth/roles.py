from enum import Enum


class Role(str, Enum):
    ADMIN = "admin"
    OPERATOR = "operator"
    ENROLLMENT = "enrollment_operator"


ROLE_INCLUDES = {
    Role.ADMIN: {Role.ADMIN, Role.OPERATOR, Role.ENROLLMENT},
    Role.OPERATOR: {Role.OPERATOR},
    Role.ENROLLMENT: {Role.ENROLLMENT, Role.OPERATOR},
}


def has_role(user_roles: set[str], required: Role) -> bool:
    for raw_role in user_roles:
        try:
            role = Role(raw_role)
        except ValueError:
            continue
        if required in ROLE_INCLUDES[role]:
            return True
    return False
