from pydantic import BaseModel
from typing import List, Dict

class SuccessResponse(BaseModel):
    meta: dict
    data: dict | list
    links: dict

class sourceItem(BaseModel):
    type: str
    location: str

class ErrorItem(BaseModel):
    status: str
    source: sourceItem | None
    title: str | None
    detail: str | None

class FailureModel(BaseModel):
    errors: List[ErrorItem]

