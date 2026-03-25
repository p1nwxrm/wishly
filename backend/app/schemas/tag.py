from pydantic import BaseModel, Field, ConfigDict # type: ignore
from typing import Optional


# ==========================================
# TAG SCHEMAS
# ==========================================

class TagBase(BaseModel):
	"""
	Shared properties for Tag objects.
	"""
	name: str = Field(..., min_length=1, max_length=50, description="Name of the tag (e.g., 'Birthday', 'Tech')")
	description: Optional[str] = Field(None, description="Optional details about the tag")


class TagCreate(TagBase):
	"""
	Properties to receive via API on tag creation.
	"""
	created_by_user_id: int = Field(..., description="ID of the user who created the tag")


class TagUpdate(BaseModel):
	"""
	Properties to receive via API on tag update.
	"""
	name: Optional[str] = Field(None, min_length=1, max_length=50)
	description: Optional[str] = None


class TagResponse(TagBase):
	"""
	Properties to return via API.
	"""
	id: int
	created_by_user_id: int

	# Enables Pydantic to read data seamlessly from SQLAlchemy ORM models
	model_config = ConfigDict(from_attributes=True)