from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict
from typing import Optional
from datetime import datetime
from app.schemas.lookups import SubscriptionPlan

# ==========================================
# 1. REQUEST SCHEMAS
# ==========================================

class UserCreate(BaseModel):
    """
    Properties to receive via API on user creation (Registration).
    """
    username: str = Field(..., min_length=3, max_length=50, pattern=r"^[a-z0-9_]+$", description="Unique username")
    name: str = Field(..., min_length=1, max_length=100, description="User's full display name")
    photo_url: Optional[str] = Field(default=None, max_length=255, description="Optional URL to the user's profile photo")
    email: EmailStr = Field(..., description="Valid email address")
    password: str = Field(..., min_length=8, description="Raw password, at least 8 characters")

    @field_validator('username')
    @classmethod
    def prevent_reserved_usernames(cls, v: str) -> str:
        reserved_words = {"me", "search", "admin", "api", "root", "system", "wishlists", "gifts"}
        if v in reserved_words:
            raise ValueError(f"The username '{v}' is reserved by the system.")
        return v


class UserUpdate(BaseModel):
    """
    Properties to receive via API on user update (PATCH request).
    """
    username: Optional[str] = Field(default=None, min_length=3, max_length=50, pattern=r"^[a-z0-9_]+$")
    name: Optional[str] = Field(default=None, min_length=2, max_length=100)
    photo_url: Optional[str] = Field(default=None, max_length=255)
    password: Optional[str] = Field(default=None, min_length=8)

    # We don't allow updating email here.
    # Usually, changing an email requires a separate confirmation flow for security.

# ==========================================
# 2. RESPONSE SCHEMAS
# ==========================================

class UserStats(BaseModel):
    """Statistics for a user profile."""
    followers_count: int = Field(default=0)
    following_count: int = Field(default=0)

    model_config = ConfigDict(from_attributes=True)


class UserRelationship(BaseModel):
    """Current user's relationship to this profile."""
    is_following: bool = Field(default=False)
    is_follower: bool = Field(default=False)

    model_config = ConfigDict(from_attributes=True)


class UserBase(BaseModel):
    """
    Core user data. Used as a building block for other models.
    """
    id: int
    username: str
    name: str
    subscription_type: SubscriptionPlan
    photo_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class PrivateUser(UserBase):
    """
    Sensitive user data, returned only to the account owner.
    """
    email: EmailStr
    created_at: datetime


class SocialUser(UserBase):
    """
    User data formatted for social interactions (feeds, lists).
    Includes connection status.
    """
    relationship: Optional[UserRelationship] = None


class UserProfile(SocialUser):
    """
    Full public profile data.
    Includes base info, relationships, and stats.
    """
    stats: UserStats