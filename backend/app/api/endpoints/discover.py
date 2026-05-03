from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user

# Initialize the router for discovery-related endpoints (Feed & Search)
router = APIRouter(prefix="/discover", tags=["Discovery"])

# ==========================================
# DISCOVERY ENDPOINTS
# ==========================================

@router.get("/feed", response_model=List[schemas.gift.SharedGift], status_code=status.HTTP_200_OK)
async def get_feed(
        skip: int = 0,
        limit: int = 20,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves the personalized feed for the current authenticated user.
    Returns a list of gifts from users they follow, including owner details
    and the booking status, ordered by newest first.
    """
    # Fetching the feed using the composites CRUD function
    feed_items = await crud.composites.get_user_feed(
        db=db,
        current_user_id=current_user.id,
        limit=limit,
        offset=skip
    )

    return feed_items


@router.get("/search", response_model=List[schemas.user.SocialUser])
async def search_for_users(
        q: str,
        limit: int = 20,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Searches for users by partial username or display name.
    Requires authentication to use the search functionality.
    """
    # Updated to require at least 1 character
    if len(q) < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Search query must be at least 1 character long."
        )

    # Fetching users using the composites CRUD function
    users = await crud.composites.search_users(
        db=db,
        search_query=q,
        current_user_id=current_user.id,
        limit=limit
    )

    return users