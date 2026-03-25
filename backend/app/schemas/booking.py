from pydantic import BaseModel, Field, ConfigDict # type: ignore
from datetime import datetime


# ==========================================
# BOOKING SCHEMAS
# ==========================================

class BookingCreate(BaseModel):
	"""
	Properties to receive when a user wants to book a gift.
	Usually, the endpoint only needs the gift_id from the URL or body,
	and the user_id comes from the authentication dependency.
	"""
	gift_id: int = Field(..., description="ID of the gift being booked")
	user_id: int = Field(..., description="ID of the user booking the gift")


class BookingResponse(BaseModel):
	"""
	Properties to return via API to confirm the booking.
	"""
	gift_id: int
	user_id: int
	created_at: datetime

	# Enables Pydantic to read data seamlessly from SQLAlchemy ORM models
	model_config = ConfigDict(from_attributes=True)