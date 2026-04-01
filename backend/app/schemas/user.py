from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict # type: ignore
from typing import Optional
from datetime import datetime

# ==========================================
# USER SCHEMAS
# ==========================================

class UserBase(BaseModel):
	"""
	Shared properties across all User schemas.
	"""
	username: str = Field(..., min_length=3, max_length=50, pattern=r"^[a-z0-9_]+$", description="Unique username")
	name: str = Field(..., min_length=2, max_length=100, description="User's full display name")
	email: EmailStr = Field(..., description="Valid email address")
	photo_url: Optional[str] = Field(None, max_length=255)

	# Added validator to protect system routes from being claimed as usernames
	# noinspection PyNestedDecorators
	@field_validator('username')
	@classmethod
	def prevent_reserved_usernames(cls, v: str) -> str:
		# A set of reserved words that cannot be used as usernames
		reserved_words = {"me", "search", "admin", "api", "root", "system", "wishlists", "gifts"}

		# Since regex already enforces lowercase, v is guaranteed to be lowercase here
		if v in reserved_words:
			raise ValueError(f"The username '{v}' is reserved by the system and cannot be used.")
		return v


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
	username: Optional[str] = Field(None, min_length=3, max_length=50, pattern=r"^[a-z0-9_]+$")
	name: Optional[str] = Field(None, min_length=2, max_length=100)
	photo_url: Optional[str] = Field(None, max_length=255)
	password: Optional[str] = Field(None, min_length=8)

	# We don't allow updating email here.
	# Usually, changing an email requires a separate confirmation flow for security.

class UserResponse(UserBase):
	"""
	Properties to return via API (excludes password).
	"""
	id: int
	subscription_type_id: int
	created_at: datetime

	# Enables Pydantic to read data seamlessly from SQLAlchemy ORM models
	model_config = ConfigDict(from_attributes=True)