from typing import List, Dict, Any, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, and_
from sqlalchemy.orm import selectinload, aliased
from app.models.models import User, UserSubscription

# ==========================================
# USER CONNECTIONS (SUBSCRIPTIONS) CRUD
# ==========================================

async def create_subscription(db: AsyncSession, subscriber_id: int, subscribed_user_id: int) -> UserSubscription:
	"""
	Creates a new subscription record, indicating a user is following another user.
	Takes raw IDs instead of a Pydantic schema for simplicity.
	"""
	db_subscription = UserSubscription(
		subscriber_id=subscriber_id,
		subscribed_user_id=subscribed_user_id
	)

	db.add(db_subscription)
	await db.commit()

	return db_subscription


async def delete_subscription(db: AsyncSession, subscriber_id: int, subscribed_user_id: int) -> bool:
	"""
	Deletes a subscription from the database (unfollows a user).
	Requires exact match of both IDs for safety.
	"""
	stmt = (
		delete(UserSubscription)
		.where(
			and_(
				UserSubscription.subscriber_id == subscriber_id,
				UserSubscription.subscribed_user_id == subscribed_user_id
			)
		)
	)
	result = await db.execute(stmt)
	await db.commit()

	return result.rowcount > 0


async def check_subscription(db: AsyncSession, subscriber_id: int, subscribed_user_id: int) -> bool:
	"""
	Checks if a specific user is following another specific user.
	Returns a simple boolean.
	"""
	stmt = select(
		select(UserSubscription.subscriber_id)
		.where(
			and_(
				UserSubscription.subscriber_id == subscriber_id,
				UserSubscription.subscribed_user_id == subscribed_user_id
			)
		)
		.exists()
	)
	return await db.scalar(stmt)


async def get_followers(
		db: AsyncSession,
		target_user_id: int,
		current_user_id: Optional[int] = None
) -> List[Dict[str, Any]]:
	"""
	Retrieves a list of users who follow the target_user_id.
	Formatted perfectly for the SocialUser Pydantic schema.
	If current_user_id is in the list, its relationship field will be None.
	"""
	stmt = (
		select(User)
		.join(UserSubscription, User.id == UserSubscription.subscriber_id)
		.where(UserSubscription.subscribed_user_id == target_user_id)
		.options(selectinload(User.subscription_type))
		.order_by(UserSubscription.created_at.desc())
	)

	if current_user_id:
		ReverseSub = aliased(UserSubscription)

		is_following_sub = (
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

		is_follower_sub = (
			select(ReverseSub.subscriber_id)
			.where(
				and_(
					ReverseSub.subscriber_id == User.id,
					ReverseSub.subscribed_user_id == current_user_id
				)
			)
			.correlate(User)
			.exists()
		)

		stmt = stmt.add_columns(
			is_following_sub.label("is_following"),
			is_follower_sub.label("is_follower")
		)

	result = await db.execute(stmt)

	followers = []
	for row in result.all():
		if current_user_id:
			db_user, is_following, is_follower = row

			# If the user in the list is ME, skip relationship calculations
			if db_user.id == current_user_id:
				relationship_data = None
			else:
				relationship_data = {
					"is_following": is_following,
					"is_follower": is_follower
				}
		else:
			db_user = row[0]
			relationship_data = None

		followers.append({
			"id": db_user.id,
			"username": db_user.username,
			"name": db_user.name,
			"photo_url": db_user.photo_url,
			"subscription_type": db_user.subscription_type,
			"relationship": relationship_data
		})

	return followers


async def get_following(
		db: AsyncSession,
		target_user_id: int,
		current_user_id: Optional[int] = None
) -> List[Dict[str, Any]]:
	"""
	Retrieves a list of users that the target_user_id is following.
	Formatted perfectly for the SocialUser Pydantic schema.
	If current_user_id is in the list, its relationship field will be None.
	"""
	stmt = (
		select(User)
		.join(UserSubscription, User.id == UserSubscription.subscribed_user_id)
		.where(UserSubscription.subscriber_id == target_user_id)
		.options(selectinload(User.subscription_type))
		.order_by(UserSubscription.created_at.desc())
	)

	# The subqueries are identical to get_followers because we are always
	# checking the relationship between current_user_id and the User.id in the loop
	if current_user_id:
		ReverseSub = aliased(UserSubscription)

		is_following_sub = (
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

		is_follower_sub = (
			select(ReverseSub.subscriber_id)
			.where(
				and_(
					ReverseSub.subscriber_id == User.id,
					ReverseSub.subscribed_user_id == current_user_id
				)
			)
			.correlate(User)
			.exists()
		)

		stmt = stmt.add_columns(
			is_following_sub.label("is_following"),
			is_follower_sub.label("is_follower")
		)

	result = await db.execute(stmt)

	following_list = []
	for row in result.all():
		if current_user_id:
			db_user, is_following, is_follower = row

			# If the user in the list is ME, skip relationship calculations
			if db_user.id == current_user_id:
				relationship_data = None
			else:
				relationship_data = {
					"is_following": is_following,
					"is_follower": is_follower
				}
		else:
			db_user = row[0]
			relationship_data = None

		following_list.append({
			"id": db_user.id,
			"username": db_user.username,
			"name": db_user.name,
			"photo_url": db_user.photo_url,
			"subscription_type": db_user.subscription_type,
			"relationship": relationship_data
		})

	return following_list