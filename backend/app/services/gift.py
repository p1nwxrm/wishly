from typing import Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app import crud
from app.models.models import Gift, Wishlist

# ==========================================
# GIFT BUSINESS LOGIC (SERVICE LAYER)
# ==========================================

async def get_gift_and_wishlist_or_404(db: AsyncSession, gift_id: int) -> Tuple[Gift, Wishlist]:
	"""
	Helper to fetch a gift and its parent wishlist.
	Raises 404 if either is missing. Used to prevent repetitive lookups.
	"""
	gift = await crud.gift.get_gift(db=db, gift_id=gift_id)
	if not gift:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

	wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=int(gift.wishlist_id))
	if not wishlist:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

	return gift, wishlist


async def verify_gift_ownership(db: AsyncSession, gift_id: int, current_user_id: int) -> Gift:
	"""
	Checks if a gift exists and if the user owns the parent wishlist.
	Returns the gift if successful, raises 403/404 otherwise.
	"""
	gift, wishlist = await get_gift_and_wishlist_or_404(db, gift_id)

	if wishlist.owner_id != current_user_id:
		raise HTTPException(
			status_code=status.HTTP_403_FORBIDDEN,
			detail="Not enough permissions to modify this gift"
		)

	return gift