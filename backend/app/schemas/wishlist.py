from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List

from app.schemas.user import SocialUser
from app.schemas.gift import GiftBase

# ==========================================
# WISHLIST SCHEMAS
# ==========================================

class WishlistCreate(BaseModel):
    """
    Properties to receive via API on wishlist creation.
    Note: In a real endpoint, 'owner_id' is usually extracted from the JWT token
    of the logged-in user, but we include it here for completeness of the schema.
    """
    title: str = Field(..., min_length=1, max_length=150, description="Title of the wishlist")
    is_visible: bool = Field(default=True, description="Whether the wishlist is public or private")


class WishlistUpdate(BaseModel):
    """
    Properties to receive via API on wishlist update (PATCH request).
    """
    title: Optional[str] = Field(default=None, min_length=1, max_length=150)
    is_visible: Optional[bool] = None


class WishlistBase(BaseModel):
    """
    Response model for Wishlist.
    """
    id: int
    title: str = Field(..., description="Title of the wishlist")
    gifts_count: int = Field(default=0, description="Number of gifts in the wishlist")
    is_visible: bool = Field(..., description="Whether the wishlist is public or private")

    model_config = ConfigDict(from_attributes=True)


class SharedWishlist(WishlistBase):
    """
    Wishlist with the owner's social profile.
    Inherits all fields from WishlistBase.
    """
    owner: SocialUser


class WishlistDetails(SharedWishlist):
    """
    Full wishlist details including the owner and the list of gifts.
    Inherits all fields from SharedWishlist (which includes WishlistBase).
    """
    gifts: List[GiftBase] = Field(default_factory=list)