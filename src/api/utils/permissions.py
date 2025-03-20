from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request
from src.api.utils.database import connect


class AccessControl(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_method = str(request.method).upper()
        resource = request.url.path[1:]
        print(resource)
        with connect(request.headers.get('db_cluster')) as conn:
            if conn.does_page_require_auth(resource, request_method):
                oID = conn.get_operator_by_token(
                    request.headers.get('user-token'))
                if oID is None:
                    raise Exception()
                if not conn.does_operator_have_permission(oID, resource,
                                                          request_method):
                    raise Exception(f"User {oID} does not have access to ")

        response = await call_next(request)
        return response
