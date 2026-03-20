from pydantic import BaseModel

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
    """
    sub: str | None = None