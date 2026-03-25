from collections.abc import AsyncGenerator
from fastapi import Depends, HTTPException, status # type: ignore
from fastapi.security import OAuth2PasswordBearer # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession
from jose import jwt, JWTError
from pydantic import ValidationError # type: ignore

# Import our project modules
from app.db.database import AsyncSessionLocal
from app.core.config import settings
from app import crud, schemas
from app.models.models import User

# ==========================================
# DATABASE DEPENDENCY
# ==========================================

async def get_db() -> AsyncGenerator[AsyncSession, None]:
	"""
	Dependency function that yields an asynchronous database session for each API request.

	Using 'yield' instead of 'return' turns this function into a context manager.
	It allows FastAPI to automatically close the session after the HTTP request is finished,
	guaranteeing that database connections are safely returned to the pool even if
	an exception occurs during request processing.
	"""
	db = AsyncSessionLocal()
	try:
		# Pauses execution here and hands the session object over to the route handler
		yield db
	finally:
		# Resumes execution after the route handler finishes and safely closes the connection
		await db.close()


# ==========================================
# AUTHENTICATION DEPENDENCIES
# ==========================================

# This tells FastAPI where the client should go to get the token.
# It is specifically used by Swagger UI to render the "Authorize" button correctly.
reusable_oauth2 = OAuth2PasswordBearer(tokenUrl=f"/auth/login")


async def get_current_user(
		db: AsyncSession = Depends(get_db),
		token: str = Depends(reusable_oauth2)
) -> User:
	"""
	Dependency to extract the JWT access token from the request header,
	validate its signature, check its expiration, and return the database User object.
	"""
	credentials_exception = HTTPException(
		status_code=status.HTTP_401_UNAUTHORIZED,
		detail="Could not validate credentials",
		headers={"WWW-Authenticate": "Bearer"},
	)

	try:
		# 1. Decode the ACCESS token using the primary SECRET_KEY
		payload = jwt.decode(
			token,
			settings.SECRET_KEY,
			algorithms=[settings.ALGORITHM]
		)

		# 2. Extract the user ID from the 'sub' claim
		user_id: str | None = payload.get("sub")
		if user_id is None:
			raise credentials_exception

		# 3. Validate the payload structure using our Pydantic schema
		token_data = schemas.TokenPayload(sub=user_id)

	except (JWTError, ValidationError):
		# Catches expired tokens, tampered signatures, or missing claims
		raise credentials_exception

	# 4. Fetch the user from the database using the correct CRUD function
	user = await crud.user.get_user_by_id(db, user_id=int(token_data.sub))

	if not user:
		raise credentials_exception

	return user