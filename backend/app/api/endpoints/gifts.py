from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user
from app.core.file_manager import save_upload_file

# Initialize the router for gift-related endpoints
router = APIRouter(prefix="/gifts", tags=["Gifts"])

# ==========================================
# GIFTS ENDPOINTS
# ==========================================
@router.post("/", response_model=schemas.gift.GiftResponse, status_code=status.HTTP_201_CREATED)
async def create_new_gift(
        gift_in: schemas.gift.GiftCreate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Creates a new gift.
    Verifies that the user owns the wishlist before adding the gift to it.
    """
    # 1. Check if the wishlist exists and belongs to the user
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=gift_in.wishlist_id)  # type: ignore

    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    if wishlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only add gifts to your own wishlists"
        )

    # 2. Create the gift using the CRUD layer
    new_gift = await crud.gift.create_gift(db=db, gift_in=gift_in)
    return new_gift


@router.post("/{gift_id}/photo", response_model=schemas.gift.GiftResponse)
async def upload_gift_photo(
    gift_id: int,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Uploads a photo for a specific gift.
    Includes a security check to ensure the user owns the parent wishlist.
    """
    # 1. Fetch the existing gift from the database
    gift = await crud.gift.get_gift(db=db, gift_id=gift_id)
    if not gift:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gift not found"
        )

    # 2. Security Check: Verify the current user owns the wishlist
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=int(gift.wishlist_id))  # type: ignore
    if not wishlist or wishlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions to modify this gift"
        )

    # 3. Save the uploaded file to the 'gifts' subfolder
    photo_url = save_upload_file(file, subfolder="gifts")

    # 4. Construct the Pydantic update schema dynamically
    gift_update_data = schemas.gift.GiftUpdate(photo_url=photo_url)

    # 5. Apply the update using your DRY and reusable CRUD function
    updated_gift = await crud.gift.update_gift(
        db=db,
        db_gift=gift,
        gift_in=gift_update_data
    )

    return updated_gift


@router.get("/{gift_id}", response_model=schemas.gift.GiftResponse)
async def read_gift(
        gift_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves a specific gift based on strict privacy rules:
    1. The owner sees their own gifts regardless of visibility.
    2. Other users can only see the gift if both the wishlist and the gift are visible.
    """
    # 1. Fetch the gift from the database
    gift = await crud.gift.get_gift(db=db, gift_id=gift_id)
    if not gift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # 2. Fetch the parent wishlist to check ownership and visibility
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=int(gift.wishlist_id))  # type: ignore

    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 3. Access Rule A: The owner can always view their own gifts
    if wishlist.owner_id == current_user.id:
        return gift

    # 4. Access Rule B: Check visibility flags for non-owners
    # If the wishlist or the specific gift is hidden, we pretend it doesn't exist (404)
    if not wishlist.is_visible or not gift.is_visible:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # If all checks pass, return the gift safely
    return gift


@router.patch("/{gift_id}", response_model=schemas.gift.GiftResponse)
async def update_existing_gift(
        gift_id: int,
        gift_in: schemas.gift.GiftUpdate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Updates an existing gift.
    Ensures the user owns the wishlist associated with this gift.
    """
    gift = await crud.gift.get_gift(db=db, gift_id=gift_id)
    if not gift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # Security check: verify wishlist ownership
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=int(gift.wishlist_id))  # type: ignore
    if not wishlist or wishlist.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not enough permissions")

    updated_gift = await crud.gift.update_gift(db=db, db_gift=gift, gift_in=gift_in)
    return updated_gift


@router.delete("/{gift_id}")
async def delete_existing_gift(
        gift_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Deletes a gift.
    Ensures the user owns the wishlist associated with this gift before deletion.
    """
    gift = await crud.gift.get_gift(db=db, gift_id=gift_id)
    if not gift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # Security check: verify wishlist ownership
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=int(gift.wishlist_id))  # type: ignore
    if not wishlist or wishlist.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not enough permissions")

    await crud.gift.delete_gift(db=db, gift_id=gift_id)

    return {"status": "success", "message": "Gift successfully deleted"}