from fastapi import HTTPException
from src.utils import HTTPStatusCodes


class UserTokenNotFoundException(HTTPException):
    def __init__(self):
        super().__init__(HTTPStatusCodes.FORBIDDEN.value,
                         "User token is not valid or has expired.")


class UnauthorizedException(HTTPException):
    def __init__(self):
        super().__init__(HTTPStatusCodes.FORBIDDEN,
                         "User does not have access to requested resource.")
