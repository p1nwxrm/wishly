from typing import List, Dict, Any
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import aliased
from app.models.models import Gift, Wishlist, User, UserSubscription, Booking


# ==========================================
# FEED CRUD OPERATIONS
# ==========================================

async def get_user_feed(db: AsyncSession, current_user_id: int, limit: int = 20, offset: int = 0) -> List[Dict[str, Any]]:
    """
    Retrieves the feed of gifts from users that the current user is subscribed to.
    Includes a boolean flag indicating mutual subscription.
    """

    # Create an alias of the UserSubscription table to check the reverse subscription,
    # so SQLAlchemy doesn't confuse it with the main table in the outer join.
    ReverseSubscription = aliased(UserSubscription)

    # Create an EXISTS subquery to check if the wishlist owner follows the current user back
    mutual_sub_query = (
        select(ReverseSubscription.subscriber_id)
        .where(
            and_(
                ReverseSubscription.subscriber_id == User.id,  # Owner of the gift
                ReverseSubscription.subscribed_user_id == current_user_id  # Current logged-in user
            )
        )
        .correlate(User)  # Explicitly specify that User is taken from the outer query
        .exists()
    )

    stmt = (
        select(
            Gift,
            User.id.label("owner_id"), # <-- Added owner_id extraction
            User.username.label("owner_username"),
	        User.name.label("owner_name"),
            User.photo_url.label("owner_photo_url"),
            Booking.user_id.label("booked_by"),
            mutual_sub_query.label("is_mutual_subscription")  # Attach the boolean flag
        )
        .join(Wishlist, Gift.wishlist_id == Wishlist.id)
        .join(User, Wishlist.owner_id == User.id)
        .join(UserSubscription, User.id == UserSubscription.subscribed_user_id)

        # Outer join to find any existing booking for this gift
        .outerjoin(Booking, Gift.id == Booking.gift_id)

        .where(
            UserSubscription.subscriber_id == current_user_id,
            Gift.is_visible == True,
            Wishlist.is_visible == True
        )
        .order_by(Gift.created_at.desc())
        .limit(limit)
        .offset(offset)
    )

    result = await db.execute(stmt)
    rows = result.all()

    feed_items = []
    for row in rows:
        feed_items.append({
            "gift": row.Gift,
            "owner": {
                "id": row.owner_id,
                "username": row.owner_username,
	            "name": row.owner_name,
                "photo_url": row.owner_photo_url
            },
            "booked_by": row.booked_by,
            "is_mutual_subscription": row.is_mutual_subscription
        })

    return feed_items