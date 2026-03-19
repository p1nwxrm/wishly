from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from datetime import datetime


# ==========================================
# WISHLIST SCHEMAS
# ==========================================

class WishlistBase(BaseModel):
	"""
	Shared properties for Wishlist objects.
	"""
	title: str = Field(..., min_length=1, max_length=150, description="Title of the wishlist")
	is_visible: bool = Field(True, description="Whether the wishlist is public or private")


class WishlistCreate(WishlistBase):
	"""
	Properties to receive via API on wishlist creation.
	Note: In a real endpoint, 'owner_id' is usually extracted from the JWT token
	of the logged-in user, but we include it here for completeness of the schema.
	"""
	owner_id: int = Field(..., description="ID of the user who owns this wishlist")


class WishlistUpdate(BaseModel):
	"""
	Properties to receive via API on wishlist update (PATCH request).
	"""
	title: Optional[str] = Field(None, min_length=1, max_length=150)
	is_visible: Optional[bool] = None


class WishlistResponse(WishlistBase):
	"""
	Properties to return via API.
	"""
	id: int
	owner_id: int
	created_at: datetime

	model_config = ConfigDict(from_attributes=True)