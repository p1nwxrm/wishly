# Export routers with distinct names to prevent namespace collisions
from .auth import router as auth_router
from .users import router as users_router
from .gifts import router as gifts_router