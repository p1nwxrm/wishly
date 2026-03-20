from typing import Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.models import Gift
from app.schemas.gift import GiftCreate, GiftUpdate


# ==========================================
# GIFT CRUD OPERATIONS
# ==========================================

async def create_gift(db: AsyncSession, gift_in: GiftCreate) -> Gift:
	"""
	Creates a new gift entry in the database.
	The wishlist_id must be provided inside the gift_in payload.
	"""
	# Convert the Pydantic schema into a standard Python dictionary
	gift_data = gift_in.model_dump()

	# Initialize the SQLAlchemy model with the unpacked dictionary data
	db_gift = Gift(**gift_data)

	# Add the new object to the session and commit the transaction to MySQL
	db.add(db_gift)
	await db.commit()

	# Refresh retrieves the newly generated ID and created_at timestamp
	await db.refresh(db_gift)

	return db_gift


async def get_gift(db: AsyncSession, gift_id: int) -> Gift | None:
	"""
	Retrieves a single gift by its primary key ID.
	Returns None if the gift does not exist.
	"""
	stmt = select(Gift).where(Gift.id == gift_id)
	result = await db.execute(stmt)

	# scalar_one_or_none() is perfect here because an ID is always unique
	return result.scalar_one_or_none()


async def get_gifts_by_wishlist(db: AsyncSession, wishlist_id: int) -> Sequence[Gift]:
	"""
	Retrieves all gifts associated with a specific wishlist.
	Useful for displaying the contents of a wishlist on the frontend.
	"""
	# We filter gifts based on the foreign key (wishlist_id)
	stmt = select(Gift).where(Gift.wishlist_id == wishlist_id)
	result = await db.execute(stmt)

	# scalars().all() extracts the Gift objects from the result rows and returns them as a list
	return result.scalars().all()


async def update_gift(db: AsyncSession, db_gift: Gift, gift_in: GiftUpdate) -> Gift:
	"""
	Updates an existing gift.
	Only modifies the fields that were explicitly sent in the request body.
	"""
	# exclude_unset=True ensures we only update fields the user actually provided,
	# preventing accidental overwrites with None values.
	update_data = gift_in.model_dump(exclude_unset=True)

	# Iterate through the provided fields and update the SQLAlchemy model dynamically
	for field, value in update_data.items():
		setattr(db_gift, field, value)

	db.add(db_gift)
	await db.commit()
	await db.refresh(db_gift)

	return db_gift


async def delete_gift(db: AsyncSession, gift_id: int) -> bool:
	"""
	Deletes a gift from the database.
	Due to the ON DELETE CASCADE constraint in our models, this will also
	automatically remove any associated bookings and gift tags.
	"""
	stmt = delete(Gift).where(Gift.id == gift_id)
	result = await db.execute(stmt)
	await db.commit()

	# rowcount indicates how many rows were successfully deleted (1 or 0)
	return result.rowcount > 0