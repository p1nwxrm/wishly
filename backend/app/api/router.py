from fastapi import APIRouter # type: ignore

# Import all individual endpoint files
from app.api.endpoints import auth, bookings, gifts, subscriptions, tags, users, wishlists

# Create a master router
api_router = APIRouter()

# Include all sub-routers
api_router.include_router(auth.router)
api_router.include_router(bookings.router)
api_router.include_router(gifts.router)
api_router.include_router(subscriptions.router)
api_router.include_router(tags.router)
api_router.include_router(users.router)
api_router.include_router(wishlists.router)
