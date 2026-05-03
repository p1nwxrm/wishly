from typing import List, Dict, Any, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, and_
from sqlalchemy.orm import selectinload
from app.models.models import Booking, Gift, Wishlist, User, GiftTag

# ==========================================
# BOOKING CRUD OPERATIONS
# ==========================================

async def create_booking(db: AsyncSession, gift_id: int, user_id: int) -> Booking:
	"""
	Creates a new booking record, indicating a user has reserved a specific gift.
	Takes direct integer IDs instead of a Pydantic schema.
	"""
	db_booking = Booking(gift_id=gift_id, user_id=user_id)

	db.add(db_booking)
	await db.commit()
	await db.refresh(db_booking)

	return db_booking


async def get_booked_by_user_id(db: AsyncSession, gift_id: int) -> Optional[int]:
	"""
	Checks if a gift is booked and returns the user_id of the person who booked it.
	Returns None if the gift is not booked.
	This is highly optimized as it only fetches a single integer column.
	"""
	stmt = select(Booking.user_id).where(Booking.gift_id == gift_id)
	result = await db.execute(stmt)
	return result.scalar_one_or_none()


async def get_bookings_by_user(db: AsyncSession, user_id: int) -> List[Gift]:
	"""
	Retrieves all gifts booked by a specific user.
	Returns a list of Gift ORM models, perfectly matched for SharedGift schema.
	"""
	stmt = (
		select(Gift)
		.join(Booking, Gift.id == Booking.gift_id)
		.join(Wishlist, Gift.wishlist_id == Wishlist.id)
		# Eagerly load all relationships needed by SharedGift schema
		.options(
			selectinload(Gift.gift_tags).joinedload(GiftTag.tag),
			selectinload(Gift.booking_info),
			# Chain load to get the owner through the wishlist
			selectinload(Gift.wishlist).selectinload(Wishlist.owner).selectinload(User.subscription_type)
		)
		.where(
			and_(
				Booking.user_id == user_id,
				Gift.is_visible == True,
				Wishlist.is_visible == True
			)
		)
		.order_by(Booking.created_at.desc())
	)

	result = await db.execute(stmt)
	return list(result.scalars().all())


async def delete_booking(db: AsyncSession, gift_id: int, user_id: int) -> bool:
	"""
	Deletes a booking from the database (cancels the reservation).
	Requires both gift_id and user_id to ensure a user can only cancel their own bookings.
	"""
	stmt = delete(Booking).where(
		Booking.gift_id == gift_id,
		Booking.user_id == user_id
	)
	result = await db.execute(stmt)
	await db.commit()

	return result.rowcount > 0