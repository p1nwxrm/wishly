from fastapi import APIRouter, Depends, HTTPException, status # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from fastapi import UploadFile, File # type: ignore
from app.core.file_manager import save_upload_file

from app import crud
from app.schemas.user import UserCreate, UserUpdate, UserResponse
from app.api.dependencies import get_db, get_current_user
from app.models.models import User

# Initialize the router.
# Prefix means all routes here will automatically start with /users (e.g., /users/register)
# Tags group these endpoints together in the Swagger UI.
router = APIRouter(prefix="/users", tags=["Users"])


# ==========================================
# USER ROUTERS
# ==========================================

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
        user_in: UserCreate,
        db: AsyncSession = Depends(get_db)
):
    """
    Registers a new user in the system.
    Returns HTTP 400 if the email is already taken.
    Password hashing and default subscription assignment are handled seamlessly by the CRUD layer.
    """
    # 1. Check if a user with this email already exists
    existing_user = await crud.user.get_user_by_email(db, email=user_in.email)

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email address already exists."
        )

    # 2. Delegate the creation, hashing, and database saving to the CRUD layer
    new_user = await crud.user.create_user(db, user_in=user_in)

    return new_user

@router.get("/me", response_model=UserResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user)
):
    """
    Returns the profile information of the currently authenticated user.
    The get_current_user dependency handles token validation and database lookup.
    """
    # The dependency already fetched the user from the DB, so we just return it!
    return current_user


@router.post("/me/photo", response_model=UserResponse)
async def upload_profile_photo(
        file: UploadFile = File(...),
        current_user: User = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    """
    Uploads a new profile picture and updates the user using the existing generic update_user CRUD.
    """
    # 1. Save the file and get the URL
    photo_url = save_upload_file(file, subfolder="profiles")

    # 2. Manually construct the Pydantic update schema
    # We only pass the photo_url, other fields will default to None
    user_update_data = UserUpdate(photo_url=photo_url)

    # 3. Pass it to your existing, powerful update function!
    updated_user = await crud.user.update_user(
        db=db,
        db_user=current_user,
        user_in=user_update_data
    )

    return updated_user