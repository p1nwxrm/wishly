from pydantic import BaseModel, Field, ConfigDict, HttpUrl # type: ignore
from typing import Optional
from datetime import datetime

# ==========================================
# GIFT SCHEMAS
# ==========================================

class GiftBase(BaseModel):
	"""
	Shared properties for Gift objects.
	"""
	name: str = Field(..., min_length=1, max_length=150)
	# gt=0 strictly enforces that the price must be greater than 0
	price_usd: float = Field(..., gt=0, description="Price must be strictly greater than 0")
	photo_url: Optional[str] = Field(None, max_length=255)

	link_url: HttpUrl = Field(..., description="Valid URL to the gift")
	is_visible: bool = True
	description: Optional[str] = None
	wishlist_id: int


class GiftCreate(GiftBase):
	"""
	Properties to receive via API on gift creation.
	"""
	pass  # Currently identical to GiftBase, but ready for future Create-specific fields


class GiftUpdate(BaseModel):
	"""
	Properties to receive via API on gift update (PATCH request).
	All fields are optional because the user might only update one field (e.g., price).
	"""
	name: Optional[str] = Field(default=None, min_length=1, max_length=150)
	price_usd: Optional[float] = Field(default=None, gt=0)
	photo_url: Optional[str] = Field(default=None, max_length=255)
	link_url: Optional[HttpUrl] = None
	is_visible: Optional[bool] = None
	description: Optional[str] = None


class GiftResponse(GiftBase):
	"""
	Properties to return via API.
	"""
	id: int
	created_at: datetime

	# Enables Pydantic to read data seamlessly from SQLAlchemy ORM models
	model_config = ConfigDict(from_attributes=True)