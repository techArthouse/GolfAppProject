# user.py
from sqlalchemy import Column, Integer, String, Enum
from sqlalchemy.orm import relationship
from . import Base


class User(Base):
    __tablename__ = 'User'

    user_id = Column(Integer, primary_key=True)
    sub = Column(String(255), unique=True)  # Unique identifier from the ID token
    email = Column(String(255), unique=True)  # User's email address
    verified = Column(Enum('verified', 'pending'), default='pending')
    player = relationship("Player", back_populates="user", uselist=False)  # One-to-one relationship

def __init__(self, email, verified='pending'):
        self.email = email
        self.verified = verified