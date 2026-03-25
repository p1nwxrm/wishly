from typing import List
from fastapi import APIRouter, Depends, HTTPException, status # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user


# Initialize the router for booking-related endpoints
router = APIRouter(prefix="/bookings", tags=["Bookings"])


# ==========================================
# BOOKING ENDPOINTS
# ==========================================

@router.post("/{gift_id}", response_model=schemas.booking.BookingResponse, status_code=status.HTTP_201_CREATED)
async def book_gift(
    gift_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Books a specific gift.
    Enforces business rules: cannot book own gifts, cannot double-book,
    gift and wishlist must be visible, and user must follow the owner.
    """
    # 1. Check if the gift exists
    gift = await crud.gift.get_gift(db=db, gift_id=gift_id)
    if not gift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # 2. Check if the wishlist exists
    wishlist = await crud.wishlist.get_wishlist(db=db, wishlist_id=int(gift.wishlist_id))  # type: ignore
    if not wishlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Wishlist not found")

    # 3. Check if the user is trying to book their own gift
    if wishlist.owner_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot book a gift from your own wishlist"
        )

    # 4. Security Check: Visibility
    # If the wishlist or the specific gift is hidden, pretend it doesn't exist
    if not wishlist.is_visible or not gift.is_visible:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")

    # 5. Security Check: Subscription
    # Verify that the current user is following the owner of the wishlist
    subscription = await crud.subscription.get_subscription(
        db=db,
        subscriber_id=int(current_user.id),  # type: ignore
        subscribed_user_id=int(wishlist.owner_id)  # type: ignore
    )
    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You must follow this user to book their gifts"
        )

    # 6. Check if the gift is already booked
    existing_booking = await crud.booking.get_booking_by_gift(db=db, gift_id=gift_id)
    if existing_booking:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This gift is already booked by someone else"
        )

    # 7. Create the booking safely using your Pydantic schema
    booking_data = schemas.booking.BookingCreate(
        gift_id=gift_id,
        user_id=int(current_user.id)  # type: ignore
    )
    new_booking = await crud.booking.create_booking(db=db, booking_in=booking_data)

    return new_booking


@router.delete("/{gift_id}", status_code=status.HTTP_200_OK)
async def unbook_gift(
    gift_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Removes a booking for a specific gift.
    """
    # 1. Check if the booking exists
    existing_booking = await crud.booking.get_booking_by_gift(db=db, gift_id=gift_id)
    if not existing_booking:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")

    # 2. Verify that the current user actually owns this booking
    if existing_booking.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only unbook your own bookings"
        )

    # 3. Delete the booking using the exact argument order from CRUD
    await crud.booking.delete_booking(
        db=db,
        gift_id=gift_id,
        user_id=int(current_user.id)  # type: ignore
    )

    return {"status": "success", "message": "Booking successfully removed"}


@router.get("/me", response_model=List[schemas.booking.BookingResponse])
async def get_my_bookings(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Retrieves all gifts booked by the current authenticated user.
    """
    # Fetching bookings using your specific CRUD function name
    bookings = await crud.booking.get_bookings_by_user(db=db, user_id=int(current_user.id))  # type: ignore
    return bookings