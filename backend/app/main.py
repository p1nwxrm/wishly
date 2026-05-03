import os
import uvicorn # type: ignore
import logging
from fastapi import FastAPI # type: ignore
from fastapi.middleware.cors import CORSMiddleware # type: ignore
from slowapi.middleware import SlowAPIMiddleware # type: ignore
from fastapi.staticfiles import StaticFiles # type: ignore

from slowapi import _rate_limit_exceeded_handler # type: ignore
from slowapi.errors import RateLimitExceeded # type: ignore
from app.api.main_router import api_router
from app.core.limiter import limiter
from app.core.middleware import ColoredLoggingMiddleware

# Disable the standard uvicorn access log
logging.getLogger("uvicorn.access").disabled = True

# Initialize the main FastAPI application instance.
# The title and description will automatically appear in the Swagger UI documentation.
app = FastAPI(
    title="Wishly API",
    description="Backend for a gift-booking and wishlist management system",
    version="1.0.0",
)


# ==========================================
# MIDDLEWARE REGISTRATION
# ==========================================
# Note: Middlewares are executed in an "onion" structure.
# We add the logging middleware first so it wraps the entire request cycle
# and accurately logs the total processing time.

# 1. Custom colored logging
app.add_middleware(ColoredLoggingMiddleware)

# 2. SlowAPI middleware to enforce global default_limits across all endpoints
app.add_middleware(SlowAPIMiddleware)

# 3. CORS (Cross-Origin Resource Sharing) allows your frontend (e.g., React or Flutter)
# to make requests to this backend.
# In production, replace "*" with specific allowed domains like ["https://my-frontend.com"].
origins = [
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==========================================
# RATE LIMITER REGISTRATION
# ==========================================
# Attach the limiter to the application state
app.state.limiter = limiter # type: ignore

# Add the custom exception handler for HTTP 429 errors
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


# ==========================================
# STATIC FILES DIRECTORY CONFIGURATION
# ==========================================
# Create the base 'uploads' directory and subfolders if they don't exist
os.makedirs("uploads/profiles", exist_ok=True)
os.makedirs("uploads/gifts", exist_ok=True)

# Mount the directory to serve files at the '/static' URL path
app.mount("/static", StaticFiles(directory="uploads"), name="static")


# ==========================================
# ROUTER REGISTRATION
# ==========================================
# Connect all routes at once
app.include_router(api_router)


# ==========================================
# HEALTH CHECK ENDPOINT
# ==========================================
@app.get("/ping", tags=["System"])
async def ping():
    """
    Simple health check endpoint to verify the server is running.
    Useful for monitoring systems and CI/CD pipelines.
    """
    return {"status": "ok", "message": "Wishly API is running smoothly!"}


# ==========================================
# ROOT ENDPOINT
# ==========================================
@app.get("/", tags=["System"])
async def root():
    """
    Simple health-check endpoint to verify that the server is successfully running.
    """
    return {
        "status": "success",
        "message": "Welcome to the Wishly API! Visit /docs for the Swagger UI."
    }


# ==========================================
# SERVER ENTRY POINT
# ==========================================
if __name__ == "__main__":
    # Runs the Uvicorn server programmatically when executing `python main.py`.
    # "app.main:app" points to the 'app' instance inside 'app/main.py'.
    # reload=True automatically restarts the server when you save code changes.
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
