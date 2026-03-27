from fastapi import APIRouter, Depends, HTTPException, status, Request # type: ignore
from fastapi.security import OAuth2PasswordRequestForm # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession
from jose import jwt, JWTError

from app import crud, schemas
from app.api import dependencies
from app.core import security
from app.core.config import settings
from app.core.limiter import limiter

router = APIRouter(prefix="/auth", tags=["Authentication"])

# ==========================================
# AUTHENTICATION ENDPOINTS
# ==========================================

@router.post("/login", response_model=schemas.Token)
@limiter.limit("5/minute")
async def login(
		request: Request,
		db: AsyncSession = Depends(dependencies.get_db),
		form_data: OAuth2PasswordRequestForm = Depends()
):
	"""
	OAuth2 compatible token login.
	Accepts an email (passed into the 'username' field) and password.
	Rate limited to 5 requests per minute to prevent brute-force attacks.
	"""
	# Use the correct CRUD function name: get_user_by_email
	user = await crud.user.get_user_by_email(db, email=form_data.username)

	# Use the correct model attribute: user.password_hash
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


@router.post("/refresh", response_model=schemas.Token)
@limiter.limit("10/minute")
async def refresh_tokens(
		request: Request,
		body: schemas.TokenRefresh,
		db: AsyncSession = Depends(dependencies.get_db)
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
		# Decode the refresh token using the specific refresh secret key
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
		# Catches tokens with invalid signatures or those past their 30-day expiration
		raise credentials_exception

	user = await crud.user.get_user_by_id(db, user_id=int(user_id))

	# Check if user exists AND if the token version matches the database
	if not user or user.token_version != token_version:
		raise credentials_exception

	# Generate a fresh pair of tokens using your security functions
	new_access_token = security.create_access_token(subject=user.id, token_version=int(user.token_version)) # type: ignore
	new_refresh_token = security.create_refresh_token(subject=user.id, token_version=int(user.token_version)) # type: ignore

	return {
		"access_token": new_access_token,
		"refresh_token": new_refresh_token,
		"token_type": "bearer"
	}
