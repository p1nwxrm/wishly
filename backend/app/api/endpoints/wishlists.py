from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user
from app.services import wishlist as wishlist_service

# Initialize the router
router = APIRouter(prefix="/wishlists", tags=["Wishlists"])

# ==========================================
# WISHLIST ROUTERS
# ==========================================

@router.post("/", response_model=schemas.wishlist.WishlistBase, status_code=status.HTTP_201_CREATED)
async def create_new_wishlist(
        wishlist_in: schemas.wishlist.WishlistCreate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    return await crud.wishlist.create_wishlist(
        db=db,
        owner_id=current_user.id,
        wishlist_in=wishlist_in
    )


@router.get("/user/{username}", response_model=schemas.composites.UserWishlists)
async def read_user_wishlists(
        username: str,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves the target user's profile and their visible wishlists.
    """
    # 1. Fetch user
    social_user = await crud.user.get_social_user_by_username(
        db=db,
        target_username=username,
        current_user_id=current_user.id
    )
    if not social_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # 2. Fetch user's wishlists (filtered by visibility inside the CRUD)
    wishlists = await crud.wishlist.get_wishlists_by_owner(
        db=db,
        target_user_id=social_user["id"],
        current_user_id=current_user.id
    )

    # 3. Pack into the composite schema
    return {
        "user": social_user,
        "wishlists": wishlists
    }


@router.get("/{wishlist_id}/gifts", response_model=schemas.wishlist.WishlistDetails)
async def read_wishlist_gifts(
        wishlist_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # 1. All business logic and filtering are hidden in the service
    return await wishlist_service.get_wishlist_details_with_privacy(
        db=db,
        wishlist_id=wishlist_id,
        current_user_id=current_user.id
    )


@router.patch("/{wishlist_id}", response_model=schemas.wishlist.WishlistBase)
async def update_existing_wishlist(
        wishlist_id: int,
        wishlist_in: schemas.wishlist.WishlistUpdate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # 1. Verify permissions via the service
    wishlist = await wishlist_service.get_owned_wishlist_or_404(db, wishlist_id, current_user.id)

    # 2. Update the wishlist
    return await crud.wishlist.update_wishlist(db=db, db_wishlist=wishlist, wishlist_in=wishlist_in)


@router.delete("/{wishlist_id}")
async def delete_existing_wishlist(
        wishlist_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # 1. Verify permissions via the service
    await wishlist_service.get_owned_wishlist_or_404(db, wishlist_id, current_user.id)

    # 2. Delete the wishlist
    await crud.wishlist.delete_wishlist(db=db, wishlist_id=wishlist_id)

    return {"status": "success", "message": "Wishlist successfully deleted"}