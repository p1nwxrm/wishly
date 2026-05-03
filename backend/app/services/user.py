from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app import crud
from app.models.models import User

# ==========================================
# USER BUSINESS LOGIC (SERVICE LAYER)
# ==========================================

async def get_user_by_username_or_404(db: AsyncSession, username: str) -> User:
    """
    Helper to resolve a username to a User model, raising 404 if not found.
    Used across multiple routers to prevent repetitive lookups and error handling.
    """
    user = await crud.user.get_user_by_username(db, username=username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"User '{username}' not found"
        )
    return user