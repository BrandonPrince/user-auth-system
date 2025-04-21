from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

# SQLAlchemy engine for MySQL connection
engine = create_engine(DATABASE_URL)
# Session factory for database interactions
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
# Base class for SQLAlchemy models
Base = declarative_base()

def get_db():
    """Provide a database session for FastAPI dependency injection.

    Yields:
        Session: Database session.

    Ensures:
        Session is closed after use.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()