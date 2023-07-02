# models/__init__.py
from .user import User
from .game import Game
from .player import Player
from .course import Course
from .round import Round
from .game_player import GamePlayer

__all__ = [
    'User', 'Game', 'Player', 'Course', 'Round', 'GamePlayer'
]
# course.py
from sqlalchemy import Column, Integer, String, DECIMAL
from sqlalchemy.orm import relationship
from db import get_db_session
from models.round import Round
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Course(Base):
    __tablename__ = 'Course'

    course_id = Column(Integer, primary_key=True)
    course_name = Column(String(255))
    course_rating = Column(DECIMAL(10, 2))
    slope_rating = Column(Integer)
    par = Column(Integer)

    rounds = relationship(Round, back_populates="course")

    @classmethod
    def insert_course(cls, course_name, course_rating, slope_rating, par):
        session = get_db_session()
        course = cls(course_name=course_name, course_rating=course_rating, slope_rating=slope_rating, par=par)
        session.add(course)
        session.commit()

    @classmethod
    def get_course(cls, course_id):
        session = get_db_session()
        course = session.query(cls).filter(cls.course_id == course_id).one()
        session.close()
        return course
# game.py
from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey
from sqlalchemy.orm import relationship
from db import get_db_session
from models.round import Round
from models.game_player import GamePlayer
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Game(Base):
    __tablename__ = 'Game'

    game_id = Column(Integer, primary_key=True)
    tournament_flag = Column(Integer)
    buy_in = Column(DECIMAL(10, 2))
    num_rounds = Column(Integer)
    game_name = Column(String(255))
    host_id = Column(Integer, ForeignKey('Player.player_id'))

    rounds = relationship(Round, back_populates="game")
    game_players = relationship(GamePlayer, back_populates="game")

    @classmethod
    def insert_game(cls, tournament_flag, buy_in, num_rounds, game_name, host_id):
        session = get_db_session()
        game = cls(tournament_flag=tournament_flag, buy_in=buy_in, num_rounds=num_rounds, game_name=game_name, host_id=host_id)
        session.add(game)
        session.commit()

    @classmethod
    def get_game(cls, game_id):
        session = get_db_session()
        game = session.query(cls).filter(cls.game_id == game_id).one()
        session.close()
        return game

    def get_game_players(self):
        return [gp.player for gp in self.game_players]

    def get_game_rounds(self):
        return self.rounds
# game_player.py
from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from db import get_db_session
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class GamePlayer(Base):
    __tablename__ = 'GamePlayer'

    game_id = Column(Integer, ForeignKey('Game.game_id'), primary_key=True)
    player_id = Column(Integer, ForeignKey('Player.player_id'), primary_key=True)

    game = relationship("Game", back_populates="game_players")
    player = relationship("Player", back_populates="game_players")

    @classmethod
    def add_player_to_game(cls, game_id, player_id):
        session = get_db_session()
        gp = cls(game_id=game_id, player_id=player_id)
        session.add(gp)
        session.commit()
# player.py
from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey
from sqlalchemy.orm import relationship
from db import get_db_session
from models.game_player import GamePlayer
from models.round import Round
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Player(Base):
    __tablename__ = 'Player'

    player_id = Column(Integer, primary_key=True, autoincrement=True)
    player_name = Column(String(255))
    user_id = Column(Integer, ForeignKey('User.user_id'), unique=True)
    handicap = Column(DECIMAL(10, 2))

    user = relationship("User", back_populates="player", uselist=False)
    rounds = relationship(Round, back_populates="player")
    game_players = relationship(GamePlayer, back_populates="player")

    @classmethod
    def insert_player(cls, player_name, user_id, handicap):
        session = get_db_session()
        player = cls(player_name=player_name, user_id=user_id, handicap=handicap)
        session.add(player)
        session.commit()

    @classmethod
    def get_player(cls, player_id):
        session = get_db_session()
        player = session.query(cls).filter(cls.player_id == player_id).one()
        session.close()
        return player

    def get_player_games(self):
        return [gp.game for gp in self.game_players]
# round.py
from sqlalchemy import Column, Integer, ForeignKey, DECIMAL
from sqlalchemy.orm import relationship
from db import get_db_session
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class Round(Base):
    __tablename__ = 'Round'

    round_id = Column(Integer, primary_key=True)
    game_id = Column(Integer, ForeignKey('Game.game_id'))
    player_id = Column(Integer, ForeignKey('Player.player_id'))
    course_id = Column(Integer, ForeignKey('Course.course_id'))
    round_num = Column(Integer)
    total_score = Column(Integer)
    handicap = Column(DECIMAL(10, 2))

    game = relationship("Game", back_populates="rounds")
    player = relationship("Player", back_populates="rounds")
    course = relationship("Course", back_populates="rounds")

    @classmethod
    def insert_round(cls, game_id, player_id, course_id, round_num, total_score, handicap):
        session = get_db_session()
        round_ = cls(game_id=game_id, player_id=player_id, course_id=course_id, round_num=round_num, total_score=total_score, handicap=handicap)
        session.add(round_)
        session.commit()

    def previous_rounds(self):
        session = get_db_session()
        rounds = session.query(Round).filter(Round.game_id == self.game_id, Round.player_id == self.player_id, Round.round_num < self.round_num).all()
        session.close()
        return rounds
# user.py
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'User'

    user_id = Column(Integer, primary_key=True)
    sub = Column(String(255), unique=True)  # Unique identifier from the ID token
    email = Column(String(255), unique=True)  # User's email address
    player = relationship("Player", back_populates="user", uselist=False)  # One-to-one relationship
