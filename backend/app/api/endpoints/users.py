from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.api.dependencies import get_db, get_current_user
from app.models.models import User
from app.core.file_manager import save_upload_file

# Initialize the router
router = APIRouter(prefix="/users", tags=["Users"])

# ==========================================
# USER ROUTERS
# ==========================================

@router.get("/me", response_model=schemas.user.PrivateUser)
async def get_my_user(
        current_user: User = Depends(get_current_user)
):
    """
    Returns the account information of the currently authenticated user.
    The get_current_user dependency handles token validation and database lookup.
    """
    # The dependency already fetched the ORM model from the DB.
    # FastAPI will automatically filter it through the PrivateUser schema.
    return current_user


@router.patch("/me", response_model=schemas.user.PrivateUser)
async def update_my_user(
        user_in: schemas.user.UserUpdate,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Updates the authenticated user's account information (name, username, password).
    """
    # Verify username uniqueness if the user is trying to change it
    if user_in.username and user_in.username != current_user.username:
        existing_user = await crud.user.get_user_by_username(db, username=user_in.username)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This username is already taken."
            )

    updated_user = await crud.user.update_user(db=db, db_user=current_user, user_in=user_in)
    return updated_user


@router.post("/me/photo", response_model=schemas.user.PrivateUser)
async def upload_my_photo(
        file: UploadFile = File(...),
        current_user: User = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    """
    Uploads a new user photo and updates the user using the existing generic update_user CRUD.
    """
    photo_url = save_upload_file(file, subfolder="profiles")

    updated_user = await crud.user.update_user_photo(
	    db=db,
	    db_user=current_user,
	    photo_url=photo_url,
    )

    return updated_user

@router.get("/profile/{username}", response_model=schemas.user.UserProfile)
async def get_user_profile(
        username: str,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves a user's full public profile by username.
    Calculates relationship status and loads followers/following statistics.
    """
    # Fetch the full profile structure in a single database query using the username
    profile_data = await crud.user.get_user_profile_by_username(
        db,
        target_username=username,
        current_user_id=current_user.id
    )

    if not profile_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")

    return profile_data


@router.get("/{username}/wishlists", response_model=schemas.composites.UserWishlists)
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