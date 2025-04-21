from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from .models import User
from .auth import hash_password, verify_password
from fastapi import HTTPException, status
from typing import Optional

def get_user_by_email(db: Session, email: str) -> User:
    """Retrieve a user by email from the database.

    Args:
        db (Session): Database session.
        email (str): User's email.

    Returns:
        User: User object or None if not found.
    """
    return db.query(User).filter(User.email == email).first()

def authenticate_user(db: Session, email: str, password: str) -> User:
    """Authenticate a user by email and password.

    Args:
        db (Session): Database session.
        email (str): User's email.
        password (str): Plain text password.

    Returns:
        User: Authenticated user object.

    Raises:
        HTTPException: If credentials are invalid (401).
    """
    user = get_user_by_email(db, email)
    if not user or not verify_password(password, user.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    return user

def update_user(db: Session, email: str, first_name: str, last_name: str) -> User:
    """Update a user's first and last name.

    Args:
        db (Session): Database session.
        email (str): User's email.
        first_name (str): New first name (optional).
        last_name (str): New last name (optional).

    Returns:
        User: Updated user object.

    Raises:
        HTTPException: If user is not found (404).
    """
    user = get_user_by_email(db, email)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    if first_name:
        user.first_name = first_name
    if last_name:
        user.last_name = last_name
    db.commit()
    db.refresh(user)
    return user

def create_user(db: Session, email: str, password: str, first_name: Optional[str], last_name: Optional[str]) -> User:
    """Create a new user in the database.

    Args:
        db (Session): Database session.
        email (str): User's email.
        password (str): Plain text password to be hashed.
        first_name (Optional[str]): User's first name.
        last_name (Optional[str]): User's last name.

    Returns:
        User: Created user object.

    Raises:
        HTTPException: If email is already registered (409) or database error (500).
    """
    # Check if email is already registered
    if get_user_by_email(db, email):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    # Create new user with hashed password
    user = User(
        email=email,
        password=hash_password(password),
        first_name=first_name,
        last_name=last_name
    )
    try:
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {str(e)}")