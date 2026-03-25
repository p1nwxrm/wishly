from pydantic import BaseModel, Field, ConfigDict # type: ignore
from typing import Optional


# ==========================================
# SUBSCRIPTION TYPE SCHEMAS (TIERS)
# ==========================================

class SubscriptionTypeBase(BaseModel):
	"""
	Shared properties for Subscription Types (e.g., Free, Pro).
	"""
	name: str = Field(..., min_length=1, max_length=50)
	description: Optional[str] = None


class SubscriptionTypeCreate(SubscriptionTypeBase):
	"""
	Properties to receive via API on tier creation (Admin only).
	"""
	pass


class SubscriptionTypeResponse(SubscriptionTypeBase):
	"""
	Properties to return via API.
	"""
	id: int

	model_config = ConfigDict(from_attributes=True)