from .booking import BookingCreate, BookingResponse
from .gift import GiftCreate, GiftUpdate, GiftResponse, SharedGift
from .subscription_type import SubscriptionTypeCreate, SubscriptionTypeResponse
from .tag import TagCreate, TagUpdate, TagResponse
from .user import UserCompact, UserCreate, UserProfile, UserUpdate, UserResponse
from .user_subscription import UserSubscriptionCreate, UserSubscriptionResponse, UserConnection
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
	"SharedGift",

    # Subscription Type
    "SubscriptionTypeCreate",
    "SubscriptionTypeResponse",

    # Tag
    "TagCreate",
    "TagUpdate",
    "TagResponse",

    # User
	"UserCompact",
    "UserCreate",
	"UserProfile",
    "UserUpdate",
    "UserResponse",

    # User Subscription
    "UserSubscriptionCreate",
    "UserSubscriptionResponse",
	"UserConnection",

    # Wishlist
    "WishlistCreate",
    "WishlistUpdate",
    "WishlistResponse",

    # Token
    "Token",
    "TokenPayload",
    "TokenRefresh",
]