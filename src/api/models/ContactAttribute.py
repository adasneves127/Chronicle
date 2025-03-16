from pydantic import BaseModel


class ContactAttribute(BaseModel):
    contactAttributeType: str
    contactAttributeValue: str
