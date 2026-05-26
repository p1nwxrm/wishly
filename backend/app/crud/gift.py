from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload

from app.models.models import Gift, GiftTag, Wishlist, User
from app.schemas.gift import GiftCreate, GiftUpdate

# ==========================================
# GIFT CRUD OPERATIONS
# ==========================================

async def create_gift(db: AsyncSession, gift_in: GiftCreate) -> Gift:
    """
        Creates a new gift entry in the database.
        The wishlist_id is provided inside the gift_in payload.
        """
    gift_data = gift_in.model_dump()
    db_gift = Gift(**gift_data)

    db.add(db_gift)
    await db.commit()
    await db.refresh(db_gift)

    return db_gift


async def get_gift(db: AsyncSession, gift_id: int) -> Optional[Gift]:
    """
    Retrieves a single gift by its primary key ID.
    Eagerly loads related 'booking_info' and 'gift_tags' to allow
    Pydantic's from_attributes=True to parse the full model.
    """
    stmt = (
        select(Gift)
        .where(Gift.id == gift_id)
        .options(
            # Eager load the booking relationship (One-to-One)
            selectinload(Gift.booking_info),
            # Eager load the association model, and then the actual tags
            selectinload(Gift.gift_tags).selectinload(GiftTag.tag)
        )
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def get_shared_gift(db: AsyncSession, gift_id: int) -> Optional[Gift]:
    """
    Retrieves a single gift along with its owner data.
    Returns a dictionary structured perfectly for the SharedGift Pydantic schema.
    """
    stmt = (
       select(Gift)
       .where(Gift.id == gift_id)
       .options(
          # 1. Load the gift's own data
          selectinload(Gift.booking_info),
          selectinload(Gift.gift_tags).selectinload(GiftTag.tag),

          # 2. Chain relationships up to the owner
          # Eager load: wishlist -> wishlist owner -> owner's subscription type
          selectinload(Gift.wishlist)
          .selectinload(Wishlist.owner)
          .selectinload(User.subscription_type)
       )
    )
    result = await db.execute(stmt)
    db_shared_gift = result.scalar_one_or_none()

    if not db_shared_gift:
        return None

    return db_shared_gift


async def update_gift(db: AsyncSession, db_gift: Gift, gift_in: GiftUpdate) -> Gift:
    """
        Updates an existing gift dynamically.
        Excludes unset values to prevent overwriting with None.
        """
    update_data = gift_in.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(db_gift, field, value)

    db.add(db_gift)
    await db.commit()
    await db.refresh(db_gift)

    return db_gift


async def update_gift_photo(db: AsyncSession, db_gift: Gift, photo_url: str) -> Gift:
    db_gift.photo_url = photo_url
    await db.commit()
    await db.refresh(db_gift)
    return db_gift


async def delete_gift(db: AsyncSession, gift_id: int) -> bool:
    """
        Deletes a gift from the database.
        Due to ON DELETE CASCADE, associated bookings and gift tags
        are automatically removed by MySQL.
        """
    stmt = delete(Gift).where(Gift.id == gift_id)
    result = await db.execute(stmt)
    await db.commit()

    return result.rowcount > 0