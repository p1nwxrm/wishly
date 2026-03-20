import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import our aggregated routers from the endpoints package
from app.api.endpoints import auth_router, users_router

# Initialize the main FastAPI application instance.
# The title and description will automatically appear in the Swagger UI documentation.
app = FastAPI(
    title="Wishly API",
    description="Backend for a gift-booking and wishlist management system",
    version="1.0.0",
)

# ==========================================
# CORS CONFIGURATION
# ==========================================
# CORS (Cross-Origin Resource Sharing) allows your frontend (e.g., React or Flutter)
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
# ROUTER REGISTRATION
# ==========================================
# Register the authentication router (login, refresh).
app.include_router(auth_router)

# Register the users router (registration, profile, etc.).
app.include_router(users_router)


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