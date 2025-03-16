from fastapi import Header
from fastapi.responses import JSONResponse
from typing import Annotated
from src.api.models.Sponsor import Sponsor
from src.api.utils.database import connect
from src.utils import HTTPStatusCodes

def post_create_sponsor(
                    sponsor: Sponsor,
                    user_token: Annotated[str | None, Header()] = None
                           ):
    sponsor_id = None
    try:
        with connect() as conn:
            sponsor_id = conn.create_sponsor(sponsor, user_token)
    except:
        pass
    if sponsor_id is None:
        return JSONResponse(content={
            "errors": [
                    {
                        "status": "400.1",
                        "title": "Could Not Create Sponsor",
                        "detail": "Unable to create sponsor. Please check "
                                  "your request and try again.\n"
                                  "No further information is available at this"
                                  " time."
                            }
                ]
        },
                            status_code=HTTPStatusCodes.BAD_REQUEST.value,
                            media_type="application/vnd.api+json")
    return JSONResponse({
                            "meta": {},
                            "data": [
                                {
                                    "message": "Sponsor created successfully",
                                    "sponsorID": sponsor_id
                                }
                            ],
                            "links": {
                                "sponsor": f"/SPONSORS?sponsorID={sponsor_id}"
                            }
                        },
                        HTTPStatusCodes.OK.value,
                        media_type="application/vnd.api+json")

