from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker # type: ignore
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

# ==========================================
# DATABASE SETUP
# ==========================================

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