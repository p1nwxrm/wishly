from passlib.context import CryptContext

# ==========================================
# SECURITY & PASSWORD HASHING
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
