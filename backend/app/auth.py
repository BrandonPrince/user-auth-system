from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()
# Initialize bcrypt context for password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
# Load JWT configuration from environment
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"

def hash_password(password: str) -> str:
    """Hash a password using bcrypt.

    Args:
        password (str): Plain text password.

    Returns:
        str: Hashed password.
    """
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against its hashed version.

    Args:
        plain_password (str): Plain text password.
        hashed_password (str): Hashed password.

    Returns:
        bool: True if passwords match, False otherwise.
    """
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict) -> str:
    """Create a JWT token with a 30-minute expiry.

    Args:
        data (dict): Payload data ({"sub": email}).

    Returns:
        str: Encoded JWT token.
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(token: str = Depends(OAuth2PasswordBearer(tokenUrl="auth/login"))) -> dict:
    """Validate JWT token and extract user data.

    Args:
        token (str): JWT token from Authorization header.

    Returns:
        dict: User data (e.g., {"email": email}).

    Raises:
        HTTPException: If token is invalid (401).
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
        return {"email": email}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")