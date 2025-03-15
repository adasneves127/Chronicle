from apiApp import app
from src.api.utils.database import connect
from src.api.models.AuthModel import AuthModel
from src.api.models.ResponseBaseModel import SuccessResponse, FailureModel
from fastapi.responses import JSONResponse
from fastapi import Response, Header
from src.utils import HTTPStatusCodes
from src.api.utils.permissions import AccessControl
from typing import Annotated
from fastapi import Request, HTTPException


@app.get("/about", include_in_schema=False)
def get_about_information():
      return {
            "SystemName": "Evenzo",
            "KnowledgeBase": "",
            "Website": "",
            "Sales": {},
            "Support": {},
            "ServerVersion": "1",
            "SystemVersion": ""
      }

@app.post("/testAPIEndpoint/test2")
def post_test_api_endpoint(
                    user_token: Annotated[str | None, Header()] = None
                           ) -> SuccessResponse | FailureModel:
    return {}


app.add_middleware(AccessControl)

@app.exception_handler(Exception)
async def unicorn_exception_handler(request: Request, exc: Exception):
        return JSONResponse(
            status_code=418,
            content={"message": f"Oops! Did something happen? There goes a rainbow..."},
        )