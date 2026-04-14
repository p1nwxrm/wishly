from typing import Sequence, List, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, and_
from sqlalchemy.orm import aliased
from app.models.models import Booking, Gift, Wishlist, User, UserSubscription
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


async def get_bookings_by_user(db: AsyncSession, user_id: int) -> List[Dict[str, Any]]:
	"""
	Retrieves all gifts booked by a specific user.
	Returns full details (gift info, owner info, mutual subscription status)
	so the frontend can render complete cards.
	"""

	# Create an alias of the UserSubscription table to check the reverse subscription
	ReverseSubscription = aliased(UserSubscription)

	# Subquery to check mutual subscription
	mutual_sub_query = (
		select(ReverseSubscription.subscriber_id)
		.where(
			and_(
				ReverseSubscription.subscriber_id == User.id,  # Owner of the gift
				ReverseSubscription.subscribed_user_id == user_id  # Current logged-in user
			)
		)
		.correlate(User)
		.exists()
	)

	stmt = (
		select(
			Gift,
			User.username.label("owner_username"),
			User.photo_url.label("owner_photo_url"),
			Booking.user_id.label("booked_by"),
			mutual_sub_query.label("is_mutual_subscription")
		)
		# Start from Booking to only get gifts this user has booked
		.join(Booking, Gift.id == Booking.gift_id)
		.join(Wishlist, Gift.wishlist_id == Wishlist.id)
		.join(User, Wishlist.owner_id == User.id)
		.where(
			Booking.user_id == user_id,
			Gift.is_visible == True,
			Wishlist.is_visible == True
		)
		# Sort by the time they booked it (newest first)
		.order_by(Booking.created_at.desc())
	)

	result = await db.execute(stmt)
	rows = result.all()

	booked_items = []
	for row in rows:
		booked_items.append({
			"gift": row.Gift,
			"owner_username": row.owner_username,
			"owner_photo_url": row.owner_photo_url,
			"booked_by": row.booked_by,
			"is_mutual_subscription": row.is_mutual_subscription
		})

	return booked_items


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