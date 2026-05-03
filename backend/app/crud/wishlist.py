from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, desc, and_
from sqlalchemy.orm import selectinload, contains_eager

from app.models.models import Wishlist, Gift, User, UserSubscription, GiftTag
from app.schemas.wishlist import WishlistCreate, WishlistUpdate

# ==========================================
# WISHLIST CRUD OPERATIONS
# ==========================================

async def create_wishlist(db: AsyncSession, owner_id: int, wishlist_in: WishlistCreate) -> Wishlist:
    """
    Creates a new wishlist for a specific user.
    Takes the owner_id directly from the endpoint (usually extracted from the JWT token).
    """
    wishlist_data = wishlist_in.model_dump()
    db_wishlist = Wishlist(owner_id=owner_id, **wishlist_data)

    db.add(db_wishlist)
    await db.commit()
    await db.refresh(db_wishlist)

    return db_wishlist


async def get_wishlist(db: AsyncSession, wishlist_id: int) -> Optional[Wishlist]:
    """
    Retrieves a simple wishlist by its ID without heavy eager loading.
    Useful for basic existence and ownership checks.
    """
    stmt = select(Wishlist).where(Wishlist.id == wishlist_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def get_wishlists_by_owner(
        db: AsyncSession,
        target_user_id: int,
        current_user_id: Optional[int] = None
) -> List[Wishlist]:
    """
    Retrieves all wishlists for a given user.
    Filters out hidden wishlists if the current user is not the owner.
    """
    stmt = select(Wishlist).where(Wishlist.owner_id == target_user_id)

    # If viewing someone else, ONLY show visible wishlists
    if current_user_id and current_user_id != target_user_id:
        stmt = stmt.where(Wishlist.is_visible == True)

    stmt = stmt.order_by(desc(Wishlist.created_at))
    result = await db.execute(stmt)

    # Return pure ORM models, Pydantic will handle the rest
    return list(result.scalars().all())


async def get_wishlist_details(
        db: AsyncSession,
        wishlist_id: int,
        current_user_id: Optional[int] = None
) -> Optional[Wishlist]:
    """
    Retrieves full details of a specific wishlist, including its gifts.
    Returns a dictionary perfectly structured for the WishlistDetails Pydantic schema.
    """
    stmt = (
        select(Wishlist, User)
        .join(User, Wishlist.owner_id == User.id)
    )

    # Eagerly load gifts, their tags, their bookings, and the owner's subscription type
    stmt = (
        stmt.options(
            contains_eager(Wishlist.owner).selectinload(User.subscription_type),
            selectinload(Wishlist.gifts).selectinload(Gift.gift_tags).joinedload(GiftTag.tag),
            selectinload(Wishlist.gifts).selectinload(Gift.booking_info)
        )
        .where(Wishlist.id == wishlist_id)
    )

    result = await db.execute(stmt)
    db_wishlist = result.scalar_one_or_none()

    if not db_wishlist:
        return None

    if db_wishlist.gifts:
        db_wishlist.gifts.sort(key=lambda gift: gift.created_at, reverse=True)

    db_owner = db_wishlist.owner

    # Calculate relationships only if viewing someone else's wishlist
    if current_user_id and current_user_id != db_owner.id:
        # Double check visibility. If it's private, and we aren't the owner, return None
        if not db_wishlist.is_visible:
            return None

        is_following_stmt = (
            select(UserSubscription)
            .where(
                and_(
                    UserSubscription.subscriber_id == current_user_id,
                    UserSubscription.subscribed_user_id == db_owner.id
                )
            )
            .exists()
        )

        is_follower_stmt = (
            select(UserSubscription)
            .where(
                and_(
                    UserSubscription.subscriber_id == db_owner.id,
                    UserSubscription.subscribed_user_id == current_user_id
                )
            )
            .exists()
        )

        is_following = await db.scalar(select(is_following_stmt))
        is_follower = await db.scalar(select(is_follower_stmt))

        setattr(db_owner, "relationship", {
            "is_following": is_following,
            "is_follower": is_follower
        })

    return db_wishlist


async def update_wishlist(db: AsyncSession, db_wishlist: Wishlist, wishlist_in: WishlistUpdate) -> Wishlist:
    """
    Updates an existing wishlist.
    Applies only the fields explicitly provided in the update schema.
    """
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
    stmt = (
        delete(Wishlist)
        .where(Wishlist.id == wishlist_id)
    )

    result = await db.execute(stmt)
    await db.commit()

    return result.rowcount > 0