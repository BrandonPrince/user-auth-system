from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from datetime import datetime

class UserLogin(BaseModel):
    """Schema for user login request."""
    email: EmailStr
    password: str

    @validator('email', 'password')
    def check_not_empty(cls, value):
        if not value or value.strip() == "":
            raise ValueError("Field cannot be empty or whitespace")
        return value

class UserUpdate(BaseModel):
    """Schema for user update request."""
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    @validator('first_name', 'last_name', pre=True)
    def check_not_empty_if_provided(cls, value):
        if value is not None and (value.strip() == ""):
            raise ValueError("Field cannot be empty or whitespace")
        return value

class UserResponse(BaseModel):
    """Schema for user response data."""
    id: int
    email: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    updated_at: str  

    @validator('updated_at', pre=True)
    def serialize_updated_at(cls, value):
        """Convert datetime to ISO string."""
        if isinstance(value, datetime):
            return value.isoformat()
        return value

    class Config:
        orm_mode = True

class UserRegister(BaseModel):
    """Schema for user registration request."""
    email: EmailStr
    password: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    @validator('email', 'password')
    def check_not_empty(cls, value):
        if not value or value.strip() == "":
            raise ValueError("Field cannot be empty or whitespace")
        return value

    @validator('first_name', 'last_name', pre=True)
    def check_not_empty_if_provided(cls, value):
        if value is not None and (value.strip() == ""):
            raise ValueError("Field cannot be empty or whitespace")
        return value