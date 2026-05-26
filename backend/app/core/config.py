from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict # type: ignore
from pydantic import Field # type: ignore
from urllib.parse import quote_plus

# ==========================================
# PATH RESOLUTION
# ==========================================
# Dynamically calculate the absolute path to the root 'backend' directory.
# __file__ refers to this current file (app/core/config.py).
# .parent.parent.parent moves up three levels: core -> app -> backend
ROOT_DIR = Path(__file__).resolve().parent.parent.parent
ENV_FILE_PATH = ROOT_DIR / ".env"

# ==========================================
# APPLICATION CONFIGURATION
# ==========================================

class Settings(BaseSettings):
	"""
	Application settings and environment variables.
	Pydantic will automatically read these from the .env file.
	"""
	# Database Settings
	DB_HOST: str = Field(default="127.0.0.1")
	DB_PORT: int = Field(default=3306)
	DB_USER: str
	DB_PASSWORD: str
	DB_NAME: str

	# JWT Security Settings
	# Security key used to cryptographically sign JWT access tokens.
	SECRET_KEY: str
	# Security key used to cryptographically sign JWT refresh tokens.
	REFRESH_SECRET_KEY: str

	# The algorithm used to sign the token (e.g., "HS256")
	ALGORITHM: str = Field(default="HS256")

	# How long the access token remains valid (in minutes)
	ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=60)
	# How long the refresh token remains valid (in days)
	REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=30)

	@property
	def DATABASE_URL(self) -> str:
		"""
		Dynamically constructs the asynchronous MySQL connection string.
		"""
		user = quote_plus(self.DB_USER)
		password = quote_plus(self.DB_PASSWORD)

		return (
			f"mysql+aiomysql://{user}:{password}"
			f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
			f"?charset=utf8mb4"
		)

	# We now pass the exact, absolute path to the .env file
	model_config = SettingsConfigDict(env_file=str(ENV_FILE_PATH), env_file_encoding="utf-8", extra="ignore")


# Create a global instance of the settings object to be imported across the app
settings = Settings()