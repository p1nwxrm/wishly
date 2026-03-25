from typing import List
from fastapi import APIRouter, Depends, HTTPException, status # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user


# Initialize the router for subscription-related endpoints
router = APIRouter(prefix="/subscriptions", tags=["Subscriptions"])


# ==========================================
# SUBSCRIPTION ENDPOINTS
# ==========================================

@router.post("/{target_user_id}", status_code=status.HTTP_201_CREATED)
async def subscribe_to_user(
    target_user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Subscribes the current user to another user.
    """
    # 1. Prevent users from subscribing to themselves
    if current_user.id == target_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot subscribe to yourself"
        )

    # 2. Check if the target user actually exists in the database
    target_user = await crud.user.get_user_by_id(db=db, user_id=target_user_id)
    if not target_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # 3. Check if the subscription already exists to prevent duplicates
    existing_subscription = await crud.subscription.get_subscription(
        db=db,
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=target_user_id
    )
    if existing_subscription:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are already subscribed to this user"
        )

    # 4. Create the subscription using the schema
    subscription_data = schemas.user_subscription.UserSubscriptionCreate(
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=target_user_id
    )
    await crud.subscription.create_subscription(db=db, subscription_in=subscription_data)

    return {"status": "success", "message": f"Successfully subscribed to user {target_user_id}"}


@router.delete("/{target_user_id}", status_code=status.HTTP_200_OK)
async def unsubscribe_from_user(
    target_user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Unsubscribes the current user from another user.
    """
    # 1. Check if the subscription actually exists
    existing_subscription = await crud.subscription.get_subscription(
        db=db,
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=target_user_id
    )
    if not existing_subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subscription not found"
        )

    # 2. Delete the subscription
    await crud.subscription.delete_subscription(
        db=db,
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=target_user_id
    )

    return {"status": "success", "message": f"Successfully unsubscribed from user {target_user_id}"}


@router.get("/followers/me", response_model=List[schemas.user_subscription.UserSubscriptionResponse])
async def get_my_followers(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Retrieves a list of users who are following the current authenticated user.
    """
    followers = await crud.subscription.get_followers(db=db, user_id=int(current_user.id))  # type: ignore
    return followers


@router.get("/following/me", response_model=List[schemas.user_subscription.UserSubscriptionResponse])
async def get_my_following(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Retrieves a list of users that the current authenticated user is following.
    """
    following = await crud.subscription.get_following(db=db, user_id=int(current_user.id))  # type: ignore
    return following