from pydantic import BaseModel, Field, ConfigDict, HttpUrl
from typing import Optional, List

from app.schemas.user import SocialUser
from app.schemas.tag import Tag

# ==========================================
# GIFT SCHEMAS
# ==========================================

class GiftCreate(BaseModel):
    """
    Properties to receive via API on gift creation.
    """
    name: str = Field(..., min_length=1, max_length=150)
    price_usd: float = Field(..., gt=0, description="Price must be strictly greater than 0")
    link_url: Optional[HttpUrl] = Field(default=None, description="Valid URL to the gift")
    is_visible: bool = True
    description: Optional[str] = None
    wishlist_id: int


class GiftUpdate(BaseModel):
    """
    Properties to receive via API on gift update (PATCH request).
    All fields are optional because the user might only update one field (e.g., price).
    """
    name: Optional[str] = Field(default=None, min_length=1, max_length=150)
    price_usd: Optional[float] = Field(default=None, gt=0, description="Price must be strictly greater than 0")
    link_url: Optional[HttpUrl] = None
    is_visible: Optional[bool] = None
    description: Optional[str] = None


class GiftBase(BaseModel):
    """
    Response model for Gift.
    Represents the full gift entity returned by the API.
    """
    id: int
    name: str
    price_usd: float
    photo_url: Optional[str] = None
    link_url: Optional[HttpUrl] = None
    is_visible: bool
    booked_by_user_id: Optional[int] = None
    tags: List[Tag] = Field(default_factory=list)
    description: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class SharedGift(GiftBase):
    """
    Represents a gift shared in a feed or booking list,
    combining the gift details with its owner's social profile.
    Inherits all fields from GiftBase.
    """
    owner: SocialUser