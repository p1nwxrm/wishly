from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud
from app.models.models import User
from app.api.dependencies import get_db, get_current_user

from app.schemas.user import SocialUser
from app.schemas.composites import UserConnections
from app.services import user as user_service

# Initialize the router for subscription-related endpoints
router = APIRouter(prefix="/connections", tags=["Connections"])

# ==========================================
# SUBSCRIPTION ENDPOINTS
# ==========================================

@router.post("/{target_username}", status_code=status.HTTP_201_CREATED)
async def subscribe_to_user(
       target_username: str,
       db: AsyncSession = Depends(get_db),
       current_user: User = Depends(get_current_user)
):
    """
    Subscribes the current user to another user by username.
    """
    # 1. Use the reusable service to find the user
    target_user = await user_service.get_user_by_username_or_404(db, target_username)

    # The unique endpoint logic remains here
    if current_user.id == target_user.id:
       raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail="You cannot subscribe to yourself"
       )

    is_subscribed = await crud.connections.check_subscription(
       db=db,
       subscriber_id=current_user.id,
       subscribed_user_id=target_user.id
    )
    if is_subscribed:
       raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail="You are already subscribed to this user"
       )

    await crud.connections.create_subscription(
       db=db, subscriber_id=current_user.id, subscribed_user_id=target_user.id
    )

    return {"status": "success", "message": f"Successfully subscribed to user {target_username}"}


@router.delete("/{target_username}", status_code=status.HTTP_200_OK)
async def unsubscribe_from_user(
       target_username: str,
       db: AsyncSession = Depends(get_db),
       current_user: User = Depends(get_current_user)
):
    """
    Unsubscribes the current user from another user by username.
    """
    # 1. Use the reusable service to find the user
    target_user = await user_service.get_user_by_username_or_404(db, target_username)

    is_subscribed = await crud.connections.check_subscription(
       db=db,
       subscriber_id=current_user.id,
       subscribed_user_id=target_user.id
    )
    if not is_subscribed:
       raise HTTPException(
          status_code=status.HTTP_404_NOT_FOUND,
          detail="Subscription not found"
       )

    await crud.connections.delete_subscription(
       db=db, subscriber_id=current_user.id, subscribed_user_id=target_user.id
    )

    return {"status": "success", "message": f"Successfully unsubscribed from user {target_username}"}


@router.get("/{target_username}/followers", response_model=List[SocialUser])
async def get_user_followers(
       target_username: str,
       db: AsyncSession = Depends(get_db),
       current_user: User = Depends(get_current_user)
):
    """
    Retrieves the list of users following the specified user.
    """
    target_user = await user_service.get_user_by_username_or_404(db, target_username)

    return await crud.connections.get_followers(
       db=db, target_user_id=target_user.id, current_user_id=current_user.id
    )


@router.get("/{target_username}/following", response_model=List[SocialUser])
async def get_user_following(
       target_username: str,
       db: AsyncSession = Depends(get_db),
       current_user: User = Depends(get_current_user)
):
    """
    Retrieves the list of users the specified user is following.
    """
    target_user = await user_service.get_user_by_username_or_404(db, target_username)

    return await crud.connections.get_following(
       db=db, target_user_id=target_user.id, current_user_id=current_user.id
    )


@router.get("/{target_username}/summary", response_model=UserConnections)
async def get_user_connection_summary(
       target_username: str,
       db: AsyncSession = Depends(get_db),
       current_user: User = Depends(get_current_user)
):
    """
    Retrieves the complete network (followers and following) for a user.
    Designed to power a unified 'Connections' screen in a single API call.
    """
    target_user = await user_service.get_user_by_username_or_404(db, target_username)

    followers = await crud.connections.get_followers(
       db=db, target_user_id=target_user.id, current_user_id=current_user.id
    )
    following = await crud.connections.get_following(
       db=db, target_user_id=target_user.id, current_user_id=current_user.id
    )

    return {
       "user": target_user,
       "followers": followers,
       "following": following
    }