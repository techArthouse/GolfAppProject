from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class User(Base):
    __tablename__ = 'User'

    user_id = Column(Integer, primary_key=True)
    sub = Column(String(255), unique=True)  # Unique identifier from the ID token
    email = Column(String(255), unique=True)  # User's email address
    player = relationship("Player", back_populates="user", uselist=False)  # One-to-one relationship


class Player(Base):
    __tablename__ = 'Player'
    player_id = Column(Integer, primary_key=True, autoincrement=True)
    player_name = Column(String(255))
    user_id = Column(Integer, ForeignKey('User.user_id'), unique=True)
    handicap = Column(DECIMAL(10, 2))  # Add this line

    user = relationship("User", back_populates="player", uselist=False)
    rounds = relationship("Round", back_populates="player")
    game_players = relationship("GamePlayer", back_populates="player")


class Game(Base):
    __tablename__ = 'Game'

    game_id = Column(Integer, primary_key=True)
    tournament_flag = Column(Integer)
    buy_in = Column(DECIMAL(10, 2))
    num_rounds = Column(Integer)
    game_name = Column(String(255))
    host_id = Column(Integer, ForeignKey('Player.player_id'))
    rounds = relationship("Round", back_populates="game")
    game_players = relationship("GamePlayer", back_populates="game")


class Course(Base):
    __tablename__ = 'Course'

    course_id = Column(Integer, primary_key=True)
    course_name = Column(String(255))
    course_rating = Column(DECIMAL(10, 2))
    slope_rating = Column(Integer)
    par = Column(Integer)

    rounds = relationship("Round", back_populates="course")


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


class GamePlayer(Base):
    __tablename__ = 'GamePlayer'

    game_id = Column(Integer, ForeignKey('Game.game_id'), primary_key=True)
    player_id = Column(Integer, ForeignKey('Player.player_id'), primary_key=True)

    game = relationship("Game", back_populates="game_players")
    player = relationship("Player", back_populates="game_players")
