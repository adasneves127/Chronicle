from pydantic import BaseModel


class UserToken(BaseModel):
    userToken: str
    createdTime: int
    expireTime: int
