from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.models import User, SubscriptionType
from app.schemas.user import UserCreate, UserUpdate

# Import the hashing function from our core security module!
from app.core.security import get_password_hash

# ==========================================
# USER CRUD OPERATIONS
# ==========================================

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
