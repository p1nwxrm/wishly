from pydantic import BaseModel, ConfigDict
from typing import List

from app.schemas.user import UserBase, SocialUser
from app.schemas.gift import SharedGift
from app.schemas.wishlist import WishlistBase

# ==========================================
# SCREEN / AGGREGATE SCHEMAS
# Complex models aggregating data for specific application screens
# ==========================================

class UserBookings(BaseModel):
    """
    'My Bookings' screen representation.
    Displays the owner of the bookings (user) and the list of booked gifts (bookings).
    """
    user: UserBase
    bookings: List[SharedGift]

    model_config = ConfigDict(from_attributes=True)


class UserWishlists(BaseModel):
    """
    User's wishlists screen representation.
    Displays the user's social profile and an array of their wishlists.
    """
    user: SocialUser
    wishlists: List[WishlistBase]

    model_config = ConfigDict(from_attributes=True)


class UserConnections(BaseModel):
    """
    'Connections' screen representation.
    Displays the target user's core data and separates their network into followers and following arrays.
    """
    user: UserBase
    followers: List[SocialUser]
    following: List[SocialUser]

    model_config = ConfigDict(from_attributes=True)