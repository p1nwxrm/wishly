from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app import crud

# ==========================================
# CONNECTION BUSINESS LOGIC (SERVICE LAYER)
# ==========================================

async def check_mutual_subscription_or_403(db: AsyncSession, user1_id: int, user2_id: int):
    """
    Checks if two users follow each other.
    Raises 403 Forbidden if the mutual subscription is missing.
    """
    user1_follows_user2 = await crud.connections.check_subscription(
        db, subscriber_id=user1_id, subscribed_user_id=user2_id
    )
    user2_follows_user1 = await crud.connections.check_subscription(
        db, subscriber_id=user2_id, subscribed_user_id=user1_id
    )

    if not user1_follows_user2 or not user2_follows_user1:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You and the wishlist owner must follow each other to perform this action"
        )