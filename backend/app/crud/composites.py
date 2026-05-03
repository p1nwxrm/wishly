from typing import List
from sqlalchemy import select, and_, or_, exists
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import aliased, selectinload
from app.models.models import Gift, Wishlist, User, UserSubscription, GiftTag

# ==========================================
# SOCIAL & FEED CRUD OPERATIONS
# ==========================================

async def search_users(
        db: AsyncSession,
        search_query: str,
        current_user_id: int,
        limit: int = 20
) -> List[User]: # <-- Возвращаем список ORM-моделей User
    """
    Searches for users using a partial match on either their unique username
    or their display name. Uses ILIKE for case-insensitive matching.
    Includes a boolean indicating if the current user follows them.
    Limits the result to prevent massive database payloads.
    """
    search_term = f"%{search_query}%"

    is_following_subquery = exists().where(
        and_(
            UserSubscription.subscriber_id == current_user_id,
            UserSubscription.subscribed_user_id == User.id
        )
    ).label("is_following")

    stmt = (
        select(User, is_following_subquery)
        .where(
            or_(
                User.username.ilike(search_term),
                User.name.ilike(search_term)
            )
        )
        .options(selectinload(User.subscription_type))
        .limit(limit)
    )

    result = await db.execute(stmt)

    users = []
    for db_user, is_following in result.all():
        db_user.relationship = {
            "is_following": is_following,
            "is_follower": False
        }
        users.append(db_user)

    return users


async def get_user_feed(
        db: AsyncSession,
        current_user_id: int,
        limit: int = 20,
        offset: int = 0
) -> List[Gift]:
    """
    Retrieves the feed of gifts from users that the current user is subscribed to.
    Includes a boolean flag indicating mutual subscription.
    Eagerly loads related tags, bookings, and user subscription types to satisfy Pydantic models.
    """
    ReverseSubscription = aliased(UserSubscription)

    is_follower_subquery = (
        select(ReverseSubscription.subscriber_id)
        .where(
            and_(
                ReverseSubscription.subscriber_id == User.id,
                ReverseSubscription.subscribed_user_id == current_user_id
            )
        )
        .correlate(User)
        .exists()
    )

    stmt = (
        select(Gift, User, is_follower_subquery.label("is_follower"))
        .join(Wishlist, Gift.wishlist_id == Wishlist.id)
        .join(User, Wishlist.owner_id == User.id)
        .join(UserSubscription, User.id == UserSubscription.subscribed_user_id)
        .options(
            selectinload(Gift.gift_tags).joinedload(GiftTag.tag),
            selectinload(Gift.booking_info),
            selectinload(User.subscription_type),
	        selectinload(Gift.wishlist).selectinload(Wishlist.owner)
        )
        .where(
            and_(
                UserSubscription.subscriber_id == current_user_id,
                Gift.is_visible == True,
                Wishlist.is_visible == True
            )
        )
        .order_by(Gift.created_at.desc())
        .limit(limit)
        .offset(offset)
    )

    result = await db.execute(stmt)

    feed_items = []
    for db_gift, db_owner, is_follower in result.all():
        db_owner.relationship = {
            "is_following": True,
            "is_follower": is_follower
        }
        feed_items.append(db_gift)

    return feed_items