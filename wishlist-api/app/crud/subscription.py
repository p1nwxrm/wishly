from typing import Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.models import UserSubscription
from app.schemas.user_subscription import UserSubscriptionCreate


# ==========================================
# USER SUBSCRIPTION CRUD OPERATIONS
# ==========================================

async def create_subscription(db: AsyncSession, subscription_in: UserSubscriptionCreate) -> UserSubscription:
	"""
	Creates a new subscription record, indicating a user is following another user.
	Requires both subscriber_id and subscribed_user_id in the payload.
	"""
	# Convert the Pydantic schema into a standard Python dictionary
	subscription_data = subscription_in.model_dump()

	# Initialize the SQLAlchemy association model
	db_subscription = UserSubscription(**subscription_data)

	# Save the new subscription to the database
	db.add(db_subscription)
	await db.commit()
	await db.refresh(db_subscription)

	return db_subscription


async def get_subscription(db: AsyncSession, subscriber_id: int, subscribed_user_id: int) -> UserSubscription | None:
	"""
	Checks if a specific user is following another specific user.
	Extremely useful for toggling the "Follow/Unfollow" button state on the frontend UI.
	"""
	stmt = select(UserSubscription).where(
		UserSubscription.subscriber_id == subscriber_id,
		UserSubscription.subscribed_user_id == subscribed_user_id
	)
	result = await db.execute(stmt)
	return result.scalar_one_or_none()


async def get_followers(db: AsyncSession, user_id: int) -> Sequence[UserSubscription]:
	"""
	Retrieves all subscription records where the given user is the target (subscribed_to).
	Essentially, returns the user's followers list.
	"""
	stmt = select(UserSubscription).where(UserSubscription.subscribed_user_id == user_id)
	result = await db.execute(stmt)

	# Return a sequence (list) of subscription objects
	return result.scalars().all()


async def get_following(db: AsyncSession, user_id: int) -> Sequence[UserSubscription]:
	"""
	Retrieves all subscription records where the given user is the actor (subscriber).
	Essentially, returns the list of people the user is following.
	"""
	stmt = select(UserSubscription).where(UserSubscription.subscriber_id == user_id)
	result = await db.execute(stmt)

	return result.scalars().all()


async def delete_subscription(db: AsyncSession, subscriber_id: int, subscribed_user_id: int) -> bool:
	"""
	Deletes a subscription from the database (unfollows a user).
	Requires exact match of both IDs for safety.
	"""
	stmt = delete(UserSubscription).where(
		UserSubscription.subscriber_id == subscriber_id,
		UserSubscription.subscribed_user_id == subscribed_user_id
	)
	result = await db.execute(stmt)
	await db.commit()

	# Return True if the unfollow action was successful
	return result.rowcount > 0