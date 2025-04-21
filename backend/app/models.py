from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.mysql import INTEGER
from .database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"
    id = Column(INTEGER, primary_key=True, autoincrement=True)
    email = Column(String(255), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    first_name = Column(String(100))
    last_name = Column(String(100))
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)