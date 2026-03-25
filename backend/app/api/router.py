from fastapi import APIRouter # type: ignore

# Import all your individual endpoint files
from app.api.endpoints import auth, users, gifts

# Create a master router
api_router = APIRouter()

# Include all sub-routers
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(gifts.router)
