from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, func, and_, or_, exists

from app.models.models import User, UserSubscription, SubscriptionType
from app.schemas.user import UserCreate, UserUpdate

from app.core.security import get_password_hash

# ==========================================
# USER CRUD OPERATIONS
# ==========================================

async def create_user(db: AsyncSession, user_in: UserCreate) -> User:
    """
    Creates a new user, hashes their password securely, and assigns the 'Free' subscription tier.
    """
    # 1. Fetch the ID of the 'Free' subscription type
    sub_stmt = select(SubscriptionType).where(SubscriptionType.name == "Free")
    sub_result = await db.execute(sub_stmt)
    free_subscription = sub_result.scalar_one_or_none()

    # 2. Hash the raw password securely using passlib from our security module
    hashed_password = get_password_hash(user_in.password)

    # 3. Convert Pydantic model to a dictionary, excluding fields we handle manually
    user_data = user_in.model_dump(exclude={"password", "subscription_type_id"})

    # 4. Inject the generated fields
    user_data["password_hash"] = hashed_password
    if free_subscription:
        user_data["subscription_type_id"] = free_subscription.id

    # 5. Create the SQLAlchemy model instance and save it
    db_user = User(**user_data)
    db.add(db_user)

    # Commit saves the data, refresh loads the generated ID and timestamps back into db_user
    await db.commit()
    await db.refresh(db_user)

    return db_user


async def get_user_by_id(db: AsyncSession, user_id: int) -> User | None:
    """
    Retrieves a user by their primary key ID.
    """
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    # scalar_one_or_none returns the object if found, or None if it doesn't exist
    return result.scalar_one_or_none()


async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    """
    Retrieves a user by their email address. Useful for login/registration checks.
    """
    stmt = select(User).where(User.email == email)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def get_user_by_username(db: AsyncSession, username: str) -> User | None:
    """
    Retrieves a user by their exact username.
    Highly useful for checking uniqueness during user registration.
    """
    stmt = select(User).where(User.username == username)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def get_user_profile_data(db: AsyncSession, username: str, current_user_id: int) -> dict | None:
    """
    Retrieves a user's profile along with their followers/following counts
    and a boolean flag indicating if the current logged-in user follows them.
    """
    followers_sq = (
        select(func.count(UserSubscription.subscriber_id))
        .where(UserSubscription.subscribed_user_id == User.id)
        .correlate(User)
        .scalar_subquery()
    )

    following_sq = (
        select(func.count(UserSubscription.subscribed_user_id))
        .where(UserSubscription.subscriber_id == User.id)
        .correlate(User)
        .scalar_subquery()
    )

    is_followed_sq = (
        select(UserSubscription.subscriber_id)
        .where(
            and_(
                UserSubscription.subscriber_id == current_user_id,
                UserSubscription.subscribed_user_id == User.id
            )
        )
        .correlate(User)
        .exists()
    )

    stmt = (
        select(
            User.id,
            User.username,
            User.name,
            User.photo_url,
            followers_sq.label("followers_count"),
            following_sq.label("following_count"),
            is_followed_sq.label("is_followed_by_me")
        )
        .where(User.username == username)
    )

    result = await db.execute(stmt)
    row = result.first()

    if not row:
        return None

    return {
        "user": {
            "id": row.id,
            "username": row.username,
            "name": row.name,
            "photo_url": row.photo_url
        },
        "followers_count": row.followers_count or 0,
        "following_count": row.following_count or 0,
        "is_followed_by_me": row.is_followed_by_me
    }


async def search_users(
        db: AsyncSession,
        search_query: str,
        current_user_id: int,
        limit: int = 20
) -> list[dict]:
    """
    Searches for users using a partial match on either their unique username
    or their display name. Uses ILIKE for case-insensitive matching.
    Includes a boolean indicating if the current user follows them.
    Limits the result to prevent massive database payloads.
    """
    search_term = f"%{search_query}%"

    is_followed_subquery = exists().where(
        and_(
            UserSubscription.subscriber_id == current_user_id,
            UserSubscription.subscribed_user_id == User.id
        )
    ).label("is_followed_by_me")

    stmt = (
        select(User, is_followed_subquery)
        .where(
            or_(
                User.username.ilike(search_term),
                User.name.ilike(search_term)
            )
        )
        .limit(limit)
    )

    result = await db.execute(stmt)

    connections = []
    for user_obj, is_followed in result.all():
        connections.append({
            "user": user_obj,
            "is_followed_by_me": is_followed
        })

    return connections


async def update_user(db: AsyncSession, db_user: User, user_in: UserUpdate) -> User:
    """
    Updates user information. Only applies changes for fields explicitly provided in the request.
    Handles password hashing automatically if a new password is provided.
    """
    # 1. Convert the Pydantic model to a dictionary.
    # exclude_unset=True is MAGIC: it only includes fields the user ACTUALLY sent in the JSON request,
    # ignoring the fields that defaulted to None.
    update_data = user_in.model_dump(exclude_unset=True)

    # 2. Check if the user wants to update their password
    if "password" in update_data:
        hashed_password = get_password_hash(update_data["password"])
        update_data["password_hash"] = hashed_password
        # Remove the raw password from the dictionary so we don't try to save it
        del update_data["password"]

    # 3. Apply the updated fields to our SQLAlchemy model instance
    for field, value in update_data.items():
        # setattr is a built-in Python function that sets the value of an attribute by its string name
        # Equivalent to: db_user.name = value
        setattr(db_user, field, value)

    # 4. Save the changes to the database
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)

    return db_user


async def invalidate_user_tokens(db: AsyncSession, db_user: User) -> User:
    """
    Increments the user's token_version to invalidate all currently active JWTs.
    """
    db_user.token_version += 1
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user


async def delete_user(db: AsyncSession, user_id: int) -> bool:
    """
    Deletes a user from the database.
    Returns True if deletion was successful, False if user wasn't found.
    """
    stmt = delete(User).where(User.id == user_id)
    result = await db.execute(stmt)
    await db.commit()

    # result.rowcount tells us how many rows were affected by the delete query
    return result.rowcount > 0
