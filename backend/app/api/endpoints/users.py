from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud
from app.schemas.user import UserCreate, UserResponse
from app.api.dependencies import get_db

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