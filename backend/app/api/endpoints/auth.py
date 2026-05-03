from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from jose import jwt, JWTError

from app import crud
from app.api.dependencies import get_db, get_current_user
from app.core import security
from app.core.config import settings
from app.core.limiter import limiter
from app.models.models import User

from app.schemas.token import TokenSet, TokenRefresh
from app.schemas.user import UserCreate, PrivateUser

# Initialize the router
router = APIRouter(prefix="/auth", tags=["Authentication"])

# ==========================================
# AUTHENTICATION ENDPOINTS
# ==========================================

@router.post("/register", response_model=PrivateUser, status_code=status.HTTP_201_CREATED)
async def register_user(
		user_in: UserCreate,
		db: AsyncSession = Depends(get_db)
):
	"""
	Registers a new user in the system.
	Returns HTTP 400 if the email or username is already taken.
	"""
	# 1. Check if email exists
	existing_user = await crud.user.get_user_by_email(db, email=str(user_in.email))
	if existing_user:
		raise HTTPException(
			status_code=status.HTTP_400_BAD_REQUEST,
			detail="A user with this email address already exists."
		)

	# 2. Check if username exists
	existing_username = await crud.user.get_user_by_username(db, username=user_in.username)
	if existing_username:
		raise HTTPException(
			status_code=status.HTTP_400_BAD_REQUEST,
			detail="This username is already taken. Please choose another one."
		)

	# 3. Create user (password hashing is done in CRUD)
	new_user = await crud.user.create_user(db, user_in=user_in)

	# Returns the PrivateUser schema (which hides the password automatically)
	return new_user


@router.post("/login", response_model=TokenSet)
@limiter.limit("5/minute")
async def login(
		request: Request,
		form_data: OAuth2PasswordRequestForm = Depends(),
		db: AsyncSession = Depends(get_db)
):
	"""
	OAuth2 compatible token login.
	Accepts an email (passed into the 'username' field) and password.
	Rate limited to 5 requests per minute to prevent brute-force attacks.
	"""
	user = await crud.user.get_user_by_email(db, email=form_data.username)

	if not user or not security.verify_password(form_data.password, str(user.password_hash)):
		raise HTTPException(
			status_code=status.HTTP_401_UNAUTHORIZED,
			detail="Incorrect email or password",
			headers={"WWW-Authenticate": "Bearer"},
		)

	access_token = security.create_access_token(subject=user.id, token_version=int(user.token_version)) # type: ignore
	refresh_token = security.create_refresh_token(subject=user.id, token_version=int(user.token_version)) # type: ignore

	return {
		"access_token": access_token,
		"refresh_token": refresh_token,
		"token_type": "bearer"
	}


@router.post("/refresh", response_model=TokenSet)
@limiter.limit("10/minute")
async def refresh_tokens(
		request: Request,
		body: TokenRefresh,
		db: AsyncSession = Depends(get_db)
):
	"""
	Takes a refresh token from the JSON body, validates its signature and expiration,
	and returns a brand new pair of access and refresh tokens.
	"""
	credentials_exception = HTTPException(
		status_code=status.HTTP_401_UNAUTHORIZED,
		detail="Invalid or expired refresh token",
		headers={"WWW-Authenticate": "Bearer"},
	)

	try:
		payload = jwt.decode(
			body.refresh_token,
			settings.REFRESH_SECRET_KEY,
			algorithms=[settings.ALGORITHM]
		)

		user_id: str | None = payload.get("sub")
		token_version: int | None = payload.get("version")

		if user_id is None or token_version is None:
			raise credentials_exception

	except JWTError:
		raise credentials_exception

	user = await crud.user.get_user_by_id(db, user_id=int(user_id))

	if not user or user.token_version != token_version:
		raise credentials_exception

	new_access_token = security.create_access_token(subject=user.id, token_version=int(user.token_version)) # type: ignore
	new_refresh_token = security.create_refresh_token(subject=user.id, token_version=int(user.token_version)) # type: ignore

	return {
		"access_token": new_access_token,
		"refresh_token": new_refresh_token,
		"token_type": "bearer"
	}


@router.post("/logout", status_code=status.HTTP_200_OK)
async def logout(
		db: AsyncSession = Depends(get_db),
		current_user: User = Depends(get_current_user)
):
	"""
	Instantly revokes ALL active tokens for the user across all devices
	by incrementing their token_version in the database.
	"""
	await crud.auth.invalidate_user_tokens(db, db_user=current_user)
	return {"detail": "Successfully logged out from all devices. Tokens revoked."}