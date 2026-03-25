from typing import List
from fastapi import APIRouter, Depends, HTTPException, status # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user

# Initialize the router for wishlist-related endpoints
router = APIRouter(prefix="/wishlists", tags=["Wishlists"])


# ==========================================
# WISHLIST ENDPOINTS
# ==========================================

@router.post("/", response_model=schemas.wishlist.WishlistResponse, status_code=status.HTTP_201_CREATED)
async def create_new_wishlist(
        # We accept WishlistBase from the user so they cannot fake the owner_id in the JSON body
        wishlist_in: schemas.wishlist.WishlistBase,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Creates a new wishlist for the currently authenticated user.
    """
    # 1. Securely inject the current user's ID into the complete Create schema
    full_wishlist_data = schemas.wishlist.WishlistCreate(
        **wishlist_in.model_dump(),
        owner_id=int(current_user.id)  # type: ignore
    )

    # 2. Save to database
    new_wishlist = await crud.wishlist.create_wishlist(db=db, wishlist_in=full_wishlist_data)
    return new_wishlist


@router.get("/me", response_model=List[schemas.wishlist.WishlistResponse])
async def read_my_wishlists(
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves all wishlists belonging to the currently authenticated user.
    """
    wishlists = await crud.wishlist.get_wishlists_by_owner(db=db, owner_id=int(current_user.id))  # type: ignore
    return wishlists


@router.get("/{wishlist_id}", response_model=schemas.wishlist.WishlistResponse)
async def read_wishlist(
        wishlist_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves a specific wishlist based on privacy and subscription rules.
    """
    # 1. Fetch the wishlist from the database
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=wishlist_id)
    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 2. Access Rule A: The owner can always view their own wishlist
    if wishlist.owner_id == current_user.id:
        return wishlist

    # 3. Access Rule B: Hide private wishlists completely (pretend it doesn't exist)
    if not wishlist.is_visible:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 4. Access Rule C: Check if the user is subscribed to the wishlist owner
    subscription = await crud.subscription.get_subscription(
        db=db,
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=int(wishlist.owner_id)  # type: ignore
    )

    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You must follow this user to view their wishlists"
        )

    # All checks passed securely
    return wishlist


@router.get("/user/{user_id}", response_model=List[schemas.wishlist.WishlistResponse])
async def read_user_wishlists(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Retrieves all visible wishlists for a specific user.
    The requesting user must be subscribed to the target user to view them.
    """
    # 1. If the user is requesting their own profile, return all their wishlists
    if user_id == current_user.id:
        return await crud.wishlist.get_wishlists_by_owner(db=db, owner_id=user_id)

    # 2. Check if the current user is subscribed to the target user
    subscription = await crud.subscription.get_subscription(
        db=db,
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=user_id
    )

    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You must follow this user to view their wishlists"
        )

    # 3. Fetch all wishlists for the target user from the database
    all_wishlists = await crud.wishlist.get_wishlists_by_owner(db=db, owner_id=user_id)

    # 4. Filter the list to only include visible wishlists
    # We use a Python list comprehension to filter the data in memory
    visible_wishlists = [wishlist for wishlist in all_wishlists if wishlist.is_visible]

    return visible_wishlists


@router.get("/{wishlist_id}/gifts", response_model=List[schemas.gift.GiftResponse])
async def read_wishlist_gifts(
    wishlist_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Retrieves all gifts for a specific wishlist.
    Applies strict privacy rules based on ownership, visibility, and subscriptions.
    """
    # 1. Fetch the wishlist
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=wishlist_id)
    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 2. Check ownership
    is_owner = (wishlist.owner_id == current_user.id)

    # 3. Enforce access rules for non-owners
    if not is_owner:
        # Hide the wishlist if it is set to private
        if not wishlist.is_visible:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

        # Check if the current user is subscribed to the owner
        subscription = await crud.subscription.get_subscription(
            db=db,
            subscriber_id=int(current_user.id),  # type: ignore
            subscribed_user_id=int(wishlist.owner_id)  # type: ignore
        )
        if not subscription:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You must follow this user to view their gifts"
            )

    # 4. Fetch all gifts from the database
    all_gifts = await crud.gift.get_gifts_by_wishlist(db=db, wishlist_id=wishlist_id)

    # 5. Filter the gifts if the user is not the owner
    if is_owner:
        # The owner sees absolutely everything
        return all_gifts
    else:
        # Followers only see gifts where is_visible == True
        # Using a list comprehension for fast filtering
        visible_gifts = [gift for gift in all_gifts if gift.is_visible]
        return visible_gifts


@router.patch("/{wishlist_id}", response_model=schemas.wishlist.WishlistResponse)
async def update_existing_wishlist(
        wishlist_id: int,
        wishlist_in: schemas.wishlist.WishlistUpdate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Updates the title or visibility of an existing wishlist.
    Only the owner is allowed to make changes.
    """
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=wishlist_id)
    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # Security check: Ensure current user is the owner
    if wishlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions to edit this wishlist"
        )

    updated_wishlist = await crud.wishlist.update_wishlist(db=db, db_wishlist=wishlist, wishlist_in=wishlist_in)
    return updated_wishlist


@router.delete("/{wishlist_id}")
async def delete_existing_wishlist(
        wishlist_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Deletes a wishlist.
    Only the owner is allowed to delete it.
    """
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=wishlist_id)
    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # Security check: Ensure current user is the owner
    if wishlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions to delete this wishlist"
        )

    await crud.wishlist.delete_wishlist(db=db, wishlist_id=wishlist_id)

    return {"status": "success", "message": "Wishlist successfully deleted"}