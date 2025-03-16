from src.api.models.AuthModel import AuthModel
from src.api.models.ResponseBaseModel import FailureModel, SuccessResponse
from fastapi import Request
from src.api.utils.database import connect
from fastapi.responses import JSONResponse
from src.utils import HTTPStatusCodes


def post_login(auth: AuthModel,
               request: Request) -> SuccessResponse | FailureModel:
    with connect() as conn:
        print(request.client.host)
        token, res = conn.doAuth(auth, request)
    if res is None:
        return JSONResponse(content={
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
            status_code=HTTPStatusCodes.UNAUTHORIZED.value,
            media_type="application/vnd.api+json"
            )
    return JSONResponse(content={
        "meta": {},
        "data": [
            res
        ],
        "links": {
            "profile": f"/OPERATORS?operatorID={res['operatorID']}"
        }
    }, media_type="application/vnd.api+json")
