from pydantic import BaseModel, Field, ConfigDict # type: ignore
from datetime import datetime

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