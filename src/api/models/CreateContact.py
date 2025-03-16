from pydantic import BaseModel
from src.api.models.ContactAttribute import ContactAttribute
from typing import List


class Contact(BaseModel):
    contactAttributes: List[ContactAttribute]
