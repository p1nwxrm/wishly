from sqlalchemy.ext.asyncio import AsyncSession
from app.models.models import User

# ==========================================
# AUTH & SECURITY CRUD OPERATIONS
# ==========================================

async def invalidate_user_tokens(db: AsyncSession, db_user: User) -> User:
	"""
	Increments the user's token_version to invalidate all currently active JWTs.
	Essential for 'logout everywhere' functionality, password resets,
	or when an account compromise is suspected.
	"""
	db_user.token_version += 1

	db.add(db_user)
	await db.commit()
	await db.refresh(db_user)

	return db_user