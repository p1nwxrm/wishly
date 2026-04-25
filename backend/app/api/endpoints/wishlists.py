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

    # 2. Fetch all wishlists for the target user from the database
    all_wishlists = await crud.wishlist.get_wishlists_by_owner(db=db, owner_id=user_id)

    # 3. Filter the list to only include visible wishlists
    # We use a Python list comprehension to filter the data in memory
    visible_wishlists = [wishlist for wishlist in all_wishlists if wishlist.is_visible]

    return visible_wishlists


@router.get("/{wishlist_id}/gifts", response_model=List[schemas.gift.SharedGift])
async def read_wishlist_gifts(
        wishlist_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves all gifts for a specific wishlist.
    Applies strict privacy rules based on ownership, visibility, and subscriptions.
    Returns a list of SharedGift objects containing extended data.
    """
    # 1. Fetch the wishlist
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=wishlist_id)
    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 2. Check ownership and visibility
    is_owner = (wishlist.owner_id == current_user.id)
    if not is_owner and not wishlist.is_visible:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 3. Fetch the owner of the wishlist via CRUD
    owner_model = await crud.user.get_user_by_id(db=db, user_id=wishlist.owner_id)

    if not owner_model:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Owner not found")

    owner_compact = schemas.user.UserCompact.model_validate(owner_model)

    # 4. Check mutual subscription via CRUD
    is_mutual = False
    if not is_owner:
        is_mutual = await crud.subscription.check_mutual_subscription(
            db=db,
            user_id_1=current_user.id,
            user_id_2=wishlist.owner_id
        )

    # 5. Fetch gifts via CRUD (booking_info is loaded automatically under the hood)
    all_gifts = await crud.wishlist.get_gifts_by_wishlist(db=db, wishlist_id=wishlist_id)

    # 6. Filter visible gifts
    visible_gifts = all_gifts if is_owner else [gift for gift in all_gifts if gift.is_visible]

    # 7. Construct SharedGift response
    shared_gifts = []
    for gift in visible_gifts:
        # Extract user_id if the gift is currently booked
        booked_by_id = gift.booking_info.user_id if gift.booking_info else None

        shared_gifts.append(
            schemas.gift.SharedGift(
                gift=schemas.gift.GiftResponse.model_validate(gift),
                owner=owner_compact,
                booked_by=booked_by_id,
                is_mutual_subscription=is_mutual
            )
        )

    return shared_gifts


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
