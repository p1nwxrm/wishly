from typing import Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.models import Tag
from app.schemas.tag import TagCreate, TagUpdate


# ==========================================
# TAG CRUD OPERATIONS
# ==========================================

async def create_tag(db: AsyncSession, tag_in: TagCreate) -> Tag:
	"""
	Creates a new tag in the database.
	The created_by_user_id must be provided in the tag_in payload.
	"""
	# Convert the Pydantic model to a standard dictionary
	tag_data = tag_in.model_dump()

	# Instantiate the SQLAlchemy model
	db_tag = Tag(**tag_data)

	# Save the new tag to the database
	db.add(db_tag)
	await db.commit()
	await db.refresh(db_tag)

	return db_tag


async def get_tag(db: AsyncSession, tag_id: int) -> Tag | None:
	"""
	Retrieves a single tag by its ID.
	Returns None if the tag does not exist.
	"""
	stmt = select(Tag).where(Tag.id == tag_id)
	result = await db.execute(stmt)
	return result.scalar_one_or_none()


async def get_tags_by_user(db: AsyncSession, user_id: int) -> Sequence[Tag]:
	"""
	Retrieves all tags created by a specific user.
	Useful for displaying a user's custom tags on the frontend.
	"""
	# Filter tags where the created_by_user_id matches the requested user
	stmt = select(Tag).where(Tag.created_by_user_id == user_id)
	result = await db.execute(stmt)

	# Return a sequence (list) of tag objects
	return result.scalars().all()


async def update_tag(db: AsyncSession, db_tag: Tag, tag_in: TagUpdate) -> Tag:
	"""
	Updates an existing tag.
	Applies only the fields explicitly provided in the update schema.
	"""
	# Exclude unset fields to prevent accidental overwrites with None
	update_data = tag_in.model_dump(exclude_unset=True)

	for field, value in update_data.items():
		setattr(db_tag, field, value)

	db.add(db_tag)
	await db.commit()
	await db.refresh(db_tag)

	return db_tag


async def delete_tag(db: AsyncSession, tag_id: int) -> bool:
	"""
	Deletes a tag from the database.
	Due to ON DELETE CASCADE constraints in the gift_tags association table,
	this tag will also be automatically removed from any gifts using it.
	"""
	stmt = delete(Tag).where(Tag.id == tag_id)
	result = await db.execute(stmt)
	await db.commit()

	# Return True if a row was actually deleted
	return result.rowcount > 0