from apiApp import app
from src.api.models.ResponseBaseModel import SuccessResponse, FailureModel
from fastapi.responses import JSONResponse
from src.api.utils.permissions import AccessControl
from src.api.endpoints.about import get_about_information
from src.api.endpoints.log_in import post_login
from src.api.endpoints.operators import get_operator
from src.api.endpoints.sponsors import createSponsor
from fastapi import Request

app.add_api_route('/about', get_about_information, include_in_schema=False)
app.add_api_route('/login', post_login, name="Log In",
                  responses={401: {"model": FailureModel},
                             200: {"model": SuccessResponse}
                             }, methods=['POST'])
app.add_api_route("/sponsor/create", createSponsor.post_create_sponsor,
                  responses={400: {"model": FailureModel},
                             200: {"model": SuccessResponse}
                             }, methods=['POST'])
app.add_api_route("/OPERATORS", get_operator.get_operator,
                  responses={404: {"model": FailureModel},
                             200: {"model": SuccessResponse}},
                             methods=['GET'])
app.add_middleware(AccessControl)


@app.exception_handler(Exception)
async def unicorn_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"message": "Oops! Something happened?"
                 " There goes a rainbow..."},
    )
