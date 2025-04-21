from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from .database import get_db, Base, engine
from .schemas import UserLogin, UserUpdate, UserResponse, UserRegister
from .crud import authenticate_user, update_user, create_user, get_user_by_email
from .auth import create_access_token, get_current_user, hash_password
from .models import User
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI application
app = FastAPI()

# Configure CORS middleware to allow cross-origin requests from Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development; restrict in production
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, PATCH, etc.)
    allow_headers=["*"],  # Allow all headers (e.g., Authorization, Content-Type)
)

# Define OAuth2 scheme for JWT token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

# Startup event to create tables and insert test user
@app.on_event("startup")
async def startup_event():
    """Create database tables and insert test user on application startup."""
    # Create all tables defined in models.py
    Base.metadata.create_all(bind=engine)
    
    # Insert test user if not exists
    with Session(engine) as db:
        existing_user = db.query(User).filter(User.email == "test@example.com").first()
        if not existing_user:
            test_user = User(
                email="test@example.com",
                password=hash_password("password"),
                first_name="Test",
                last_name="User"
            )
            db.add(test_user)
            db.commit()

@app.post("/auth/register", response_model=UserResponse)
async def register(user: UserRegister, db: Session = Depends(get_db)):
    """Register a new user.

    Args:
        user (UserRegister): Pydantic model with email, password, first_name, and last_name.
        db (Session): Database session dependency.

    Returns:
        UserResponse: Created user data.

    Raises:
        HTTPException: If email is already registered (409) or other errors.
    """
    try:
        # Create new user using CRUD function
        new_user = create_user(
            db,
            email=user.email,
            password=user.password,
            first_name=user.first_name,
            last_name=user.last_name
        )
        return new_user
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Registration error: {str(e)}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")

@app.post("/auth/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    """Authenticate user and return a JWT token.

    Args:
        user (UserLogin): Pydantic model with email and password.
        db (Session): Database session dependency.

    Returns:
        dict: Contains access_token and token_type.

    Raises:
        HTTPException: If credentials are invalid (401).
    """
    # Verify user credentials using CRUD function
    user_db = authenticate_user(db, user.email, user.password)
    if not user_db:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    # Generate JWT token with user's email
    access_token = create_access_token(data={"sub": user_db.email})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/user/me", response_model=UserResponse)
async def get_current_user_details(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Retrieve details of the currently authenticated user.

    Args:
        current_user (dict): User data extracted from JWT token.
        db (Session): Database session dependency.

    Returns:
        UserResponse: Current user's data.

    Raises:
        HTTPException: If user is not found (404).
    """
    # Fetch user by email from JWT
    user = get_user_by_email(db, current_user["email"])
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

@app.patch("/user/update", response_model=UserResponse)
async def update_user_details(
    user_update: UserUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user's first and last name.

    Args:
        user_update (UserUpdate): Pydantic model with optional first_name and last_name.
        current_user (dict): User data extracted from JWT token.
        db (Session): Database session dependency.

    Returns:
        UserResponse: Updated user data.

    Raises:
        HTTPException: If user is not found (404).
    """
    # Update user in database using CRUD function
    updated_user = update_user(
        db, current_user["email"], user_update.first_name, user_update.last_name
    )
    return updated_user