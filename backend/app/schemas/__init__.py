"""
This module aggregates all Pydantic schemas used across the application.
By importing them here, we provide a clean, single-point API for other modules
(e.g., you can just use `from app import schemas` and access `schemas.UserCreate`).
"""

# ==========================================
# LOOKUPS & TOKENS
# ==========================================
from .lookups import SubscriptionPlan
from .token import TokenSet, TokenPayload, TokenRefresh

# ==========================================
# CORE ENTITIES (Requests & Responses)
# ==========================================
from .user import (
    UserCreate,
    UserUpdate,
    UserStats,
    UserRelationship,
    UserBase,
    PrivateUser,
    SocialUser,
    UserProfile,
)

from .tag import (
    TagCreate,
    TagUpdate,
    Tag,
)

from .gift import (
    GiftCreate,
    GiftUpdate,
    GiftBase,
    SharedGift,
)

from .wishlist import (
    WishlistCreate,
    WishlistUpdate,
    WishlistBase,
    SharedWishlist,
    WishlistDetails,
)

# ==========================================
# COMPOSITES / SCREENS
# Complex aggregated models for specific UI screens
# ==========================================
from .composites import (
    UserBookings,
    UserWishlists,
    UserConnections,
)

# ==========================================
# PUBLIC API DEFINITION
# ==========================================
__all__ = [
	# Lookups & Tokens
	"SubscriptionPlan",
	"TokenSet",
	"TokenPayload",
	"TokenRefresh",

	# User
	"UserCreate",
	"UserUpdate",
	"UserStats",
	"UserRelationship",
	"UserBase",
	"PrivateUser",
	"SocialUser",
	"UserProfile",

	# Tag
	"TagCreate",
	"TagUpdate",
	"Tag",

	# Gift
	"GiftCreate",
	"GiftUpdate",
	"GiftBase",
	"SharedGift",

	# Wishlist
	"WishlistCreate",
	"WishlistUpdate",
	"WishlistBase",
	"SharedWishlist",
	"WishlistDetails",

	# Composites
	"UserBookings",
	"UserWishlists",
	"UserConnections",
]