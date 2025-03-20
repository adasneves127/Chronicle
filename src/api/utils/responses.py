from fastapi.responses import JSONResponse
from apiApp import app
from src.utils import HTTPStatusCodes

class SuccessResponse(JSONResponse):
    def __init__(self, content: dict | list,
                 statusCode: HTTPStatusCodes | int =
                        HTTPStatusCodes.OK):
        new_content = {
            "meta": {
                "appName": app.title,
                "apiVersion": app.version
            },
            "data": content
        }
        super().__init__(new_content, statusCode.value
                            if type(statusCode) is HTTPStatusCodes
                            else statusCode,
                         media_type="application/vnd.api+json")

class FailureResponse(JSONResponse):
    def __init__(self, errorContent: dict | list,
                 statusCode: HTTPStatusCodes | int =
                        HTTPStatusCodes.INTERNAL_SERVER_ERROR):
        new_content = {
            "meta": {
                "appName": app.title,
                "apiVersion": app.version
            },
            "error": errorContent
        }
        super().__init__(new_content,
                         status_code=statusCode.value
                            if type(statusCode) is HTTPStatusCodes
                            else statusCode,
                         media_type="application/vnd.api+json")
