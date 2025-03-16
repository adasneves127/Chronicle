from pydantic import BaseModel
from src.api.models.SponsorAttribute import SponsorAttribute
from typing import List


class Sponsor(BaseModel):
    sponsorName: str
    sponsorAttributes: List[SponsorAttribute]
