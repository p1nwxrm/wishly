from typing import Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app import crud
from app.models.models import Wishlist, Gift

# ==========================================
# WISHLIST BUSINESS LOGIC (SERVICE LAYER)
# ==========================================

async def get_owned_wishlist_or_404(db: AsyncSession, wishlist_id: int, current_user_id: int) -> Wishlist:
    """
    Checks if a wishlist exists and if the user has permission to modify it.
    """
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=wishlist_id)
    if not wishlist:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wishlist not found"
        )

    if wishlist.owner_id != current_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions to modify this wishlist"
        )

    return wishlist


async def get_wishlist_details_with_privacy(db: AsyncSession, wishlist_id: int, current_user_id: int) -> Dict[str, Any]:
    """
    Retrieves full wishlist details and filters gifts based on privacy rules.
    Returns a dictionary compatible with WishlistDetails schema.
    """
    # 1. Fetch the wishlist ORM object with all relations
    wishlist = await crud.wishlist.get_wishlist_details(
       db=db,
       wishlist_id=wishlist_id,
       current_user_id=current_user_id
    )

    if not wishlist:
       raise HTTPException(
          status_code=status.HTTP_404_NOT_FOUND,
          detail="Wishlist not found or is private"
       )

    # 2. Get the full list of gifts from the ORM object
    all_gifts = wishlist.gifts

    # 3. Apply privacy rules: filter out hidden gifts if requester is not the owner
    if wishlist.owner_id != current_user_id:
       all_gifts = [gift for gift in all_gifts if gift.is_visible]

    # 4. Return a dictionary that matches WishlistDetails schema structure
    return {
        "id": wishlist.id,
        "title": wishlist.title,
        "is_visible": wishlist.is_visible,
        "gifts_count": len(all_gifts),
        "owner": wishlist.owner,
        "gifts": all_gifts
    }