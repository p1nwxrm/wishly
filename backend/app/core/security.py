from datetime import datetime, timedelta, timezone
from typing import Any
from jose import jwt
from passlib.context import CryptContext
from app.core.config import settings

# ==========================================
# PASSWORD HASHING CONFIGURATION
# ==========================================

# Initialize the CryptContext using the bcrypt algorithm.
# The 'deprecated="auto"' argument is a great feature: it ensures that if you
# ever upgrade your hashing algorithm in the future, older/weaker hashes
# are automatically identified and can be flagged for an upgrade.
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password: str) -> str:
    """
    Takes a plain text password and returns a securely hashed string using bcrypt.
    The resulting string contains the algorithm identifier, the cost factor,
    the randomly generated salt, and the actual hash.
    This is the string that MUST be saved to the database.
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Compares a plain text password (e.g., provided by the user during a login attempt)
    against the hashed password retrieved from the MySQL database.

    Returns:
       bool: True if the passwords match, False otherwise.
    """
    # pwd_context.verify automatically extracts the salt from the hashed_password,
    # applies it to the plain_password, hashes it, and securely compares the results.
    return pwd_context.verify(plain_password, hashed_password)


# ==========================================
# JWT TOKEN GENERATION
# ==========================================

def create_access_token(subject: str | Any, token_version: int, expires_delta: timedelta | None = None) -> str:
    """
    Creates a short-lived JSON Web Token (Access Token).
    This token is attached to API requests to prove the user's identity.
    """
    # 'sub' (subject) is the standard JWT claim for the user identifier (e.g., user ID or email)
    to_encode: dict[str, Any] = {"sub": str(subject), "version": token_version}

    # Calculate expiration time
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    # Add expiration timestamp to the payload
    to_encode.update({"exp": expire})

    # Sign the token using the primary SECRET_KEY
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    return encoded_jwt


def create_refresh_token(subject: str | Any, token_version: int, expires_delta: timedelta | None = None) -> str:
    """
    Creates a long-lived JSON Web Token (Refresh Token).
    This token is used strictly to request a new Access Token when the old one expires.
    """
    to_encode: dict[str, Any] = {"sub": str(subject), "version": token_version}

    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    to_encode.update({"exp": expire})

    # Sign the token using the dedicated REFRESH_SECRET_KEY for enhanced security
    encoded_jwt = jwt.encode(to_encode, settings.REFRESH_SECRET_KEY, algorithm=settings.ALGORITHM)

    return encoded_jwt