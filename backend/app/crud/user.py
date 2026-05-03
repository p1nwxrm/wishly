from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload

from app.models.models import User, UserSubscription, SubscriptionType
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash

# ==========================================
# PRIVATE HELPERS (DRY Principle)
# ==========================================

async def _get_user_by_condition(db: AsyncSession, condition) -> Optional[User]:
    """
    Internal helper to fetch a user and eagerly load their subscription type.
    """
    stmt = select(User).where(condition).options(selectinload(User.subscription_type))
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def _build_social_user_dict(
       db: AsyncSession,
       target_user: User,
       current_user_id: Optional[int]
) -> Dict[str, Any]:
    """
    Internal helper to calculate relationships and format the core social user dictionary.
    Does NOT include stats.
    """
    relationship_data = None

    if current_user_id and current_user_id != target_user.id:
       # Extremely fast existence checks directly against the association table
       is_following = await db.scalar(
          select(1).where(
             UserSubscription.subscriber_id == current_user_id,
             UserSubscription.subscribed_user_id == target_user.id
          ).limit(1)
       ) is not None

       is_follower = await db.scalar(
          select(1).where(
             UserSubscription.subscriber_id == target_user.id,
             UserSubscription.subscribed_user_id == current_user_id
          ).limit(1)
       ) is not None

       relationship_data = {
          "is_following": is_following,
          "is_follower": is_follower
       }

    return {
       "id": target_user.id,
       "username": target_user.username,
       "name": target_user.name,
       "photo_url": target_user.photo_url,
       "subscription_type": target_user.subscription_type,
       "relationship": relationship_data
    }

# ==========================================
# USER CRUD OPERATIONS
# ==========================================

async def create_user(db: AsyncSession, user_in: UserCreate) -> User:
    """
    Creates a new user, hashes their password securely, and assigns the 'Free' subscription tier.
    """
    stmt = select(SubscriptionType).where(SubscriptionType.name == "Free")
    free_subscription = (await db.execute(stmt)).scalar_one_or_none()

    user_data = user_in.model_dump(exclude={"password"})
    user_data["password_hash"] = get_password_hash(user_in.password)

    if free_subscription:
       user_data["subscription_type_id"] = free_subscription.id

    db_user = User(**user_data)
    db.add(db_user)
    await db.commit()

    return await get_user_by_id(db, db_user.id)  # type: ignore


# --- Base User Fetchers (No Stats) ---

async def get_user_by_id(db: AsyncSession, user_id: int) -> Optional[User]:
    """Retrieves a user by their primary key ID."""
    return await _get_user_by_condition(db, User.id == user_id)


async def get_user_by_username(db: AsyncSession, username: str) -> Optional[User]:
    """Retrieves a user by their exact username."""
    return await _get_user_by_condition(db, User.username == username)


async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
    """Retrieves a user by their exact email address."""
    return await _get_user_by_condition(db, User.email == email)


# --- Social User Fetchers (No Stats) ---

async def get_social_user_by_id(
       db: AsyncSession,
       target_user_id: int,
       current_user_id: Optional[int] = None
) -> Optional[Dict[str, Any]]:
    """
    Retrieves a user's social data by their ID (perfect for SocialUser schema).
    """
    target_user = await get_user_by_id(db, target_user_id)
    if not target_user:
       return None

    return await _build_social_user_dict(db, target_user, current_user_id)


async def get_social_user_by_username(
       db: AsyncSession,
       target_username: str,
       current_user_id: Optional[int] = None
) -> Optional[Dict[str, Any]]:
    """
    Retrieves a user's social data by their username.
    """
    target_user = await get_user_by_username(db, target_username)
    if not target_user:
       return None

    return await _build_social_user_dict(db, target_user, current_user_id)


# --- Full Profile Fetchers (Includes Stats) ---

async def get_user_profile_by_id(
       db: AsyncSession,
       target_user_id: int,
       current_user_id: Optional[int] = None
) -> Optional[Dict[str, Any]]:
    """
    Retrieves a user's full profile data by their ID.
    """
    target_user = await get_user_by_id(db, target_user_id)
    if not target_user:
       return None

    profile_dict = await _build_social_user_dict(db, target_user, current_user_id)
    profile_dict["stats"] = {
        "followers_count": target_user.followers_count,
        "following_count": target_user.following_count
    }
    return profile_dict


async def get_user_profile_by_username(
       db: AsyncSession,
       target_username: str,
       current_user_id: Optional[int] = None
) -> Optional[Dict[str, Any]]:
    """
    Retrieves a user's full profile data directly by their username.
    """
    target_user = await get_user_by_username(db, target_username)
    if not target_user:
       return None

    profile_dict = await _build_social_user_dict(db, target_user, current_user_id)
    profile_dict["stats"] = {
        "followers_count": target_user.followers_count,
        "following_count": target_user.following_count
    }
    return profile_dict


async def update_user(db: AsyncSession, db_user: User, user_in: UserUpdate) -> User:
    """
    Updates user information dynamically based on provided fields.
    """
    update_data = user_in.model_dump(exclude_unset=True)

    if "password" in update_data:
       update_data["password_hash"] = get_password_hash(update_data["password"])
       del update_data["password"]

    for field, value in update_data.items():
       setattr(db_user, field, value)

    db.add(db_user)
    await db.commit()

    return await get_user_by_id(db, db_user.id)  # type: ignore


async def delete_user(db: AsyncSession, user_id: int) -> bool:
    """
    Deletes a user from the database.
    """
    stmt = delete(User).where(User.id == user_id)
    result = await db.execute(stmt)
    await db.commit()

    return result.rowcount > 0