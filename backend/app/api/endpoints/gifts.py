from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud
from app.models.models import User
from app.api.dependencies import get_db, get_current_user
from app.core.file_manager import save_upload_file

from app.schemas.gift import GiftCreate, GiftUpdate, SharedGift

from app.services import gift as gift_service
from app.services import wishlist as wishlist_service

# Initialize the router
router = APIRouter(prefix="/gifts", tags=["Gifts"])


# ==========================================
# GIFTS ENDPOINTS
# ==========================================

@router.post("/", response_model=SharedGift, status_code=status.HTTP_201_CREATED)
async def create_new_gift(
        gift_in: GiftCreate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Creates a new gift.
    """
    await wishlist_service.get_owned_wishlist_or_404(db, gift_in.wishlist_id, current_user.id)

    # 1. Create the gift
    new_gift = await crud.gift.create_gift(db=db, gift_in=gift_in)

    # 2. Fetch the gift again via get_gift so SQLAlchemy eagerly loads relationships (e.g., tags).
    # Without this, Pydantic might raise a MissingGreenlet exception when trying to read the tags.
    full_gift = await crud.gift.get_gift(db=db, gift_id=new_gift.id)

    # 3. Dynamically attach the owner to the ORM object.
    # Pydantic will read this attribute automatically due to from_attributes=True.
    full_gift.owner = current_user

    return full_gift


@router.post("/{gift_id}/photo", response_model=SharedGift)
async def upload_gift_photo(
        gift_id: int,
        file: UploadFile = File(...),
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Uploads a photo for a specific gift.
    """
    gift = await gift_service.verify_gift_ownership(db, gift_id, current_user.id)

    photo_url = save_upload_file(file, subfolder="gifts")
    gift_update_data = GiftUpdate(photo_url=photo_url)

    updated_gift = await crud.gift.update_gift(db=db, db_gift=gift, gift_in=gift_update_data)

    # Load relationships for Pydantic validation
    full_gift = await crud.gift.get_gift(db, updated_gift.id)

    # Attach owner dynamically
    full_gift.owner = current_user

    return full_gift


@router.get("/{gift_id}", response_model=SharedGift)
async def read_gift(
        gift_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    db_gift = await crud.gift.get_shared_gift(db=db, gift_id=gift_id)

    if not db_gift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    owner = db_gift.wishlist.owner

    if owner.id != current_user.id:
        if not db_gift.wishlist.is_visible or not db_gift.is_visible:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    return db_gift


@router.patch("/{gift_id}", response_model=SharedGift)
async def update_existing_gift(
        gift_id: int,
        gift_in: GiftUpdate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Updates an existing gift.
    """
    gift = await gift_service.verify_gift_ownership(db, gift_id, current_user.id)
    updated_gift = await crud.gift.update_gift(db=db, db_gift=gift, gift_in=gift_in)

    # Load relationships
    full_gift = await crud.gift.get_gift(db, updated_gift.id)

    # Attach owner dynamically
    full_gift.owner = current_user

    return full_gift


@router.delete("/{gift_id}")
async def delete_existing_gift(
        gift_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Deletes a gift.
    """
    gift = await gift_service.verify_gift_ownership(db, gift_id, current_user.id)
    await crud.gift.delete_gift(db=db, gift_id=gift.id)

    return {"status": "success", "message": "Gift successfully deleted"}