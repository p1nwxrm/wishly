from pydantic import BaseModel # type: ignore

# ==========================================
# TOKEN RESPONSE SCHEMAS
# ==========================================

class Token(BaseModel):
    """
    Schema for the JWT token response returned upon successful login.
    Contains both the short-lived access token and the long-lived refresh token.
    """
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    """
    Schema for the data encoded inside the JWT payload.
    'sub' (subject) typically holds the user's unique identifier (e.g., email or ID).
    'version' tracks the token generation iteration for server-side invalidation.
    """
    sub: str | None = None
    version: int | None = None


# ==========================================
# TOKEN REQUEST SCHEMAS
# ==========================================

class TokenRefresh(BaseModel):
    """
    Schema for securely receiving the refresh token in the request body.
    """
    refresh_token: str