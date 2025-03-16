from fastapi import Header
from typing import Annotated

def get_operator(user_token: Annotated[str | None, Header()] = None):
    pass
