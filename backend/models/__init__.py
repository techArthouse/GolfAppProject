# models/__init__.py

from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

# The model imports go here.
# It's important that the models are imported after `Base` is defined
# and in the correct order of dependency. If a model doesn't depend
# on any other, it can be imported first.
from .user import User
from .player import Player
from .course import Course
from .game import Game
from .round import Round
from .game_player import GamePlayer

# Expose metadata after importing all models
metadata = Base.metadata

__all__ = [
    'User', 'Game', 'Player', 'Course', 'Round', 'GamePlayer',
    'Base', 'metadata'
]
