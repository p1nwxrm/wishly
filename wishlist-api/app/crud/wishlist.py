from typing import Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.models import Wishlist
from app.schemas.wishlist import WishlistCreate, WishlistUpdate


# ==========================================
# WISHLIST CRUD OPERATIONS
# ==========================================

async def create_wishlist(db: AsyncSession, wishlist_in: WishlistCreate) -> Wishlist:
	"""
	Creates a new wishlist for a specific user.
	The owner_id must be provided within the wishlist_in schema.
	"""
	# Convert the Pydantic model to a standard dictionary
	wishlist_data = wishlist_in.model_dump()

	# Instantiate the SQLAlchemy model
	db_wishlist = Wishlist(**wishlist_data)

	# Save the new wishlist to the database
	db.add(db_wishlist)
	await db.commit()
	await db.refresh(db_wishlist)

	return db_wishlist


async def get_wishlist(db: AsyncSession, wishlist_id: int) -> Wishlist | None:
	"""
	Retrieves a single wishlist by its ID.
	Returns None if the wishlist does not exist.
	"""
	stmt = select(Wishlist).where(Wishlist.id == wishlist_id)
	result = await db.execute(stmt)
	return result.scalar_one_or_none()


async def get_wishlists_by_owner(db: AsyncSession, owner_id: int) -> Sequence[Wishlist]:
	"""
	Retrieves all wishlists created by a specific user.
	"""
	# Filter wishlists where the owner_id matches the requested user
	stmt = select(Wishlist).where(Wishlist.owner_id == owner_id)
	result = await db.execute(stmt)

	# Return a sequence (list) of wishlist objects
	return result.scalars().all()


async def update_wishlist(db: AsyncSession, db_wishlist: Wishlist, wishlist_in: WishlistUpdate) -> Wishlist:
	"""
	Updates an existing wishlist.
	Applies only the fields explicitly provided in the update schema.
	"""
	# Exclude unset fields to prevent accidental overwrites with None
	update_data = wishlist_in.model_dump(exclude_unset=True)

	for field, value in update_data.items():
		setattr(db_wishlist, field, value)

	db.add(db_wishlist)
	await db.commit()
	await db.refresh(db_wishlist)

	return db_wishlist


async def delete_wishlist(db: AsyncSession, wishlist_id: int) -> bool:
	"""
	Deletes a wishlist from the database.
	Due to ON DELETE CASCADE constraints, all gifts associated with
	this wishlist will also be permanently deleted.
	"""
	stmt = delete(Wishlist).where(Wishlist.id == wishlist_id)
	result = await db.execute(stmt)
	await db.commit()

	# Return True if a row was actually deleted
	return result.rowcount > 0