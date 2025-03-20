from src.api.models.AuthModel import AuthModel
from src.api.models.ResponseBaseModel import FailureModel, SuccessModel
from fastapi import Request, Header
from src.api.utils.database import connect
from fastapi.responses import JSONResponse
from src.utils import HTTPStatusCodes
from src.api.utils.responses import SuccessResponse, FailureResponse
from typing import Annotated

def post_login(auth: AuthModel,
               request: Request,
               db_cluster: Annotated[str | None, Header()] = None) -> SuccessModel | FailureModel:
    with connect(db_cluster) as conn:
        print(request.client.host)
        token, res = conn.doAuth(auth, request)
    if res is None:
        return FailureResponse({
                "errors": [
                    {
                        "status": "401.1",
                        "title": "Invalid Username or Password",
                        "detail": "Please check your credentials. "
                            "If you continue to have errors, "
                            "please contact the support center."
                            }
                ]
            },
            HTTPStatusCodes.UNAUTHORIZED.value,
            )
    return SuccessResponse({
        "meta": {},
        "data": [
            res | {"token": token} |{"links": {
            "profile": f"/OPERATORS?operatorID={res['operatorID']}",
            "logout": f"/logout?token={token}"
        }}
        ],
        
    })
