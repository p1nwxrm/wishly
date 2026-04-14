from typing import List
from fastapi import APIRouter, Depends, status  # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user

# Initialize the router for feed-related endpoints
router = APIRouter(prefix="/feed", tags=["Feed"])

# ==========================================
# FEED ENDPOINTS
# ==========================================

@router.get("/", response_model=List[schemas.gift.SharedGift], status_code=status.HTTP_200_OK)
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
	# Fetching the feed using the CRUD function
	# Passing limit and skip for pagination support
	feed_items = await crud.feed.get_user_feed(
		db=db,
		current_user_id=int(current_user.id), # type: ignore
		limit=limit,
		offset=skip
	)

	return feed_items