from typing import Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.models import Booking
from app.schemas.booking import BookingCreate


# ==========================================
# BOOKING CRUD OPERATIONS
# ==========================================

async def create_booking(db: AsyncSession, booking_in: BookingCreate) -> Booking:
	"""
	Creates a new booking record, indicating a user has reserved a specific gift.
	The gift_id and user_id must be provided in the payload.
	"""
	# Convert the Pydantic model to a standard dictionary
	booking_data = booking_in.model_dump()

	# Instantiate the SQLAlchemy model
	db_booking = Booking(**booking_data)

	# Save the new booking to the database
	db.add(db_booking)
	await db.commit()
	await db.refresh(db_booking)

	return db_booking


async def get_booking_by_gift(db: AsyncSession, gift_id: int) -> Booking | None:
	"""
	Retrieves the booking record for a specific gift.
	Since one gift can only have one booker, this returns a single Booking or None.
	"""
	stmt = select(Booking).where(Booking.gift_id == gift_id)
	result = await db.execute(stmt)
	return result.scalar_one_or_none()


async def get_bookings_by_user(db: AsyncSession, user_id: int) -> Sequence[Booking]:
	"""
	Retrieves all gifts booked by a specific user.
	Useful for displaying a "My Booked Gifts" tab on the frontend.
	"""
	# Filter bookings where the user_id matches the requested user
	stmt = select(Booking).where(Booking.user_id == user_id)
	result = await db.execute(stmt)

	# Return a sequence (list) of booking objects
	return result.scalars().all()


async def delete_booking(db: AsyncSession, gift_id: int, user_id: int) -> bool:
	"""
	Deletes a booking from the database (cancels the reservation).
	We require both gift_id and user_id to ensure a user can only cancel their own bookings.
	"""
	# Delete the exact match for safety
	stmt = delete(Booking).where(
		Booking.gift_id == gift_id,
		Booking.user_id == user_id
	)
	result = await db.execute(stmt)
	await db.commit()

	# Return True if the booking was successfully deleted
	return result.rowcount > 0