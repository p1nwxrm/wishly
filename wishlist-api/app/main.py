import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# We will import our endpoint routers here once they are created.
# from app.api.endpoints import users, gifts, wishlists

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
# Uncomment these lines once the router files are created in app/api/endpoints/

# app.include_router(users.router, prefix="/api/users", tags=["Users"])
# app.include_router(gifts.router, prefix="/api/gifts", tags=["Gifts"])
# app.include_router(wishlists.router, prefix="/api/wishlists", tags=["Wishlists"])


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
# SERVER ENTRY POINT
# ==========================================
if __name__ == "__main__":
    # Runs the Uvicorn server programmatically when executing `python main.py`.
    # "app.main:app" points to the 'app' instance inside 'app/main.py'.
    # reload=True automatically restarts the server when you save code changes.
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)