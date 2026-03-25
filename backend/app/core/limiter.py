from slowapi import Limiter # type: ignore
from slowapi.util import get_remote_address # type: ignore

# ==========================================
# RATE LIMITER CONFIGURATION
# ==========================================
# Initialize the rate limiter using the client's IP address.
# We set a global default limit of 100 requests per minute per IP.
# This protects all endpoints from basic spam and scraping by default.
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["100/minute"]
)