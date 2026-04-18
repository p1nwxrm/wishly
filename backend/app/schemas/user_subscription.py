from pydantic import BaseModel, Field, ConfigDict # type: ignore
from datetime import datetime
from app.schemas import UserCompact

# ==========================================
# USER SUBSCRIPTION SCHEMAS (FOLLOWERS)
# ==========================================

class UserSubscriptionCreate(BaseModel):
    """
    Properties to receive when a user follows another user.
    """
    subscribed_user_id: int = Field(..., description="ID of the user being followed")
    subscriber_id: int = Field(..., description="ID of the user who is following")


class UserSubscriptionResponse(BaseModel):
    """
    Properties to return via API.
    """
    subscriber_id: int
    subscribed_user_id: int
    created_at: datetime

    # Enables Pydantic to read data seamlessly from SQLAlchemy ORM models
    model_config = ConfigDict(from_attributes=True)


class UserConnection(BaseModel):
    """
    Represents a user in a followers/following list, including the mutual connection status.
    """
    user: UserCompact
    is_followed_by_me: bool = False

    model_config = ConfigDict(from_attributes=True)