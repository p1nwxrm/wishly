from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession

# Importing the session maker we created earlier in database.py
from app.db.database import AsyncSessionLocal


# ==========================================
# DATABASE DEPENDENCY
# ==========================================

async def get_db() -> AsyncGenerator[AsyncSession, None]:
	"""
	Dependency function that yields an asynchronous database session for each API request.

	Using 'yield' instead of 'return' turns this function into a context manager.
	It allows FastAPI to automatically close the session after the HTTP request is finished,
	guaranteeing that database connections are safely returned to the pool even if
	an exception occurs during request processing.
	"""
	db = AsyncSessionLocal()
	try:
		# Pauses execution here and hands the session object over to the route handler
		yield db
	finally:
		# Resumes execution after the route handler finishes and safely closes the connection
		await db.close()