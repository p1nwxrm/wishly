from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase

# Database connection string (using the asynchronous aiomysql driver)
# Format: dialect+driver://username:password@host:port/database
DATABASE_URL = "mysql+aiomysql://username:password@localhost/wishly_db"

# 'echo=True' logs all generated SQL statements to the console for debugging.
# Set this to False in a production environment.
engine = create_async_engine(DATABASE_URL, echo=True)

# 'expire_on_commit=False' is required for async SQLAlchemy.
# It prevents the session from implicitly making synchronous lazy-loading database
# requests to refresh object attributes after a commit, which would cause errors.
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

class Base(DeclarativeBase):
    """
    Base class for all SQLAlchemy ORM models.
    It automatically maintains a catalog (metadata) of all tables and classes.
    """
    pass