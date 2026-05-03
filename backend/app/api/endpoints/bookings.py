from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud
from app.models.models import User
from app.api.dependencies import get_db, get_current_user

from app.schemas.composites import UserBookings
from app.services import connections as connections_service
from app.services import gift as gift_service

# Initialize the router for booking-related endpoints
router = APIRouter(prefix="/bookings", tags=["Bookings"])

# ==========================================
# BOOKING ENDPOINTS
# ==========================================

@router.post("/{gift_id}", status_code=status.HTTP_201_CREATED)
async def book_gift(
        gift_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Books a specific gift.
    Enforces business rules: cannot book own gifts, cannot double-book,
    gift and wishlist must be visible, and users must follow each other.
    """
    # 1. Fetch gift and wishlist using the reusable service helper
    gift, wishlist = await gift_service.get_gift_and_wishlist_or_404(db, gift_id)

    # 2. Check if the user is trying to book their own gift
    if wishlist.owner_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot book a gift from your own wishlist"
        )

    # 3. Security Check: Visibility
    if not wishlist.is_visible or not gift.is_visible:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # 4. Security Check: Mutual Subscription
    await connections_service.check_mutual_subscription_or_403(
        db=db, user1_id=current_user.id, user2_id=wishlist.owner_id
    )

    # 5. Check if the gift is already booked
    booked_by_user_id = await crud.booking.get_booked_by_user_id(db=db, gift_id=gift_id)
    if booked_by_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This gift is already booked by someone else"
        )

    # 6. Create the booking safely via IDs
    await crud.booking.create_booking(db=db, gift_id=gift_id, user_id=current_user.id)

    return {"status": "success", "message": "Gift successfully booked"}


@router.delete("/{gift_id}", status_code=status.HTTP_200_OK)
async def unbook_gift(
        gift_id: int,
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Removes a booking for a specific gift.
    """
    # 1. Check if the booking exists and get the user who booked it
    booked_by_user_id = await crud.booking.get_booked_by_user_id(db=db, gift_id=gift_id)
    if not booked_by_user_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")

    # 2. Verify that the current user actually owns this booking
    if booked_by_user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only unbook your own bookings"
        )

    # 3. Delete the booking
    await crud.booking.delete_booking(db=db, gift_id=gift_id, user_id=current_user.id)

    return {"status": "success", "message": "Booking successfully removed"}


@router.get("/me", response_model=UserBookings)
async def get_my_bookings(
        db: AsyncSession = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Retrieves all gifts booked by the current authenticated user.
    Returns a unified 'My Bookings' screen representation.
    """
    # Fetching bookings
    bookings = await crud.booking.get_bookings_by_user(db=db, user_id=current_user.id)

    # Pack into the composite schema
    return {
        "user": current_user,
        "bookings": bookings
    }