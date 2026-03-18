from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional
from datetime import datetime


# ==========================================
# USER SCHEMAS
# ==========================================

class UserBase(BaseModel):
	"""
	Shared properties across all User schemas.
	"""
	name: str = Field(..., min_length=2, max_length=100, description="User's full name")
	email: EmailStr = Field(..., description="Valid email address")
	photo_url: Optional[str] = Field(None, max_length=255)
	subscription_type_id: int = Field(..., description="ID of the user's subscription tier")


class UserCreate(UserBase):
	"""
	Properties to receive via API on user creation (Registration).
	"""
	# We require a strong password for creation, but it won't be in the response
	password: str = Field(..., min_length=8, description="Raw password, at least 8 characters")


class UserUpdate(BaseModel):
	"""
	Properties to receive via API on user update (PATCH request).
	All fields are optional, so the user can update only specific data.
	"""
	name: Optional[str] = Field(None, min_length=2, max_length=100)
	photo_url: Optional[str] = Field(None, max_length=255)
	# If they want to change the password
	password: Optional[str] = Field(None, min_length=8)

	# Notice we don't allow updating email here.
	# Usually, changing an email requires a separate confirmation flow for security.

class UserResponse(UserBase):
	"""
	Properties to return via API (excludes password).
	"""
	id: int
	created_at: datetime

	# Enables Pydantic to read data seamlessly from SQLAlchemy ORM models
	model_config = ConfigDict(from_attributes=True)