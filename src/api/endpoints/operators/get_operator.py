from fastapi import Header
from typing import Annotated
from src.api.utils.database import connect
from src.api.utils.responses import SuccessResponse

def get_operator(user_token: Annotated[str | None, Header()] = None,
                 db_cluster: Annotated[str | None, Header()] = None,
                 operatorID: str | None = None):
    if operatorID is None:
        # Get all operators
        with connect(db_cluster) as conn:
            return SuccessResponse(conn.get_all_operators())
    # Get only one operator.
    with connect(db_cluster) as conn:
        return SuccessResponse(conn.get_operator(operatorID))
