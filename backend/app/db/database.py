from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker # type: ignore
from sqlalchemy.orm import DeclarativeBase

# Import our global settings object to safely access environment variables
from app.core.config import settings

# ==========================================
# DATABASE SETUP
# ==========================================

# We no longer hardcode the database URL. We dynamically fetch it from validated settings.
# 'echo=True' logs all generated SQL statements to the console for debugging.
# Remember to set this to False in a production environment.
engine = create_async_engine(settings.DATABASE_URL, echo=False, pool_pre_ping=True)

# 'expire_on_commit=False' is strictly required for async SQLAlchemy.
# It prevents the session from implicitly making synchronous lazy-loading requests
# to refresh object attributes after a transaction commit.
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

class Base(DeclarativeBase):
    """
    Base class for all SQLAlchemy ORM models.
    It automatically maintains a catalog (metadata) of all tables and classes.
    """
    pass