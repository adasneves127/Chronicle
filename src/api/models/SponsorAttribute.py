from pydantic import BaseModel


class SponsorAttribute(BaseModel):
    sponsorAttributeType: str
    sponsorAttributeValue: str
