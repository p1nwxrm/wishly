from .booking import BookingCreate, BookingResponse
from .gift import GiftCreate, GiftUpdate, GiftResponse
from .subscription_type import SubscriptionTypeCreate, SubscriptionTypeResponse
from .tag import TagCreate, TagUpdate, TagResponse
from .user import UserCreate, UserUpdate, UserResponse
from .user_subscription import UserSubscriptionCreate, UserSubscriptionResponse
from .wishlist import WishlistCreate, WishlistUpdate, WishlistResponse
from .token import Token, TokenPayload, TokenRefresh

# Define __all__ to explicitly declare the public API of the core package.
# This tells other developers (and IDEs) exactly what is safe to import.
__all__ = [
    # Booking
    "BookingCreate",
    "BookingResponse",

    # Gift
    "GiftCreate",
    "GiftUpdate",
    "GiftResponse",

    # Subscription Type
    "SubscriptionTypeCreate",
    "SubscriptionTypeResponse",

    # Tag
    "TagCreate",
    "TagUpdate",
    "TagResponse",

    # User
    "UserCreate",
    "UserUpdate",
    "UserResponse",

    # User Subscription
    "UserSubscriptionCreate",
    "UserSubscriptionResponse",

    # Wishlist
    "WishlistCreate",
    "WishlistUpdate",
    "WishlistResponse",

    # Token
    "Token",
    "TokenPayload",
    "TokenRefresh",
]