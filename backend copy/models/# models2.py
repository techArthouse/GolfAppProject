# models.py

from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey, Numeric
from sqlalchemy.orm import relationship
from db import get_db_session

Base = declarative_base()

# ... existing model definitions here ...

# adding methods
class Game(Base):
    # ... existing fields here ...

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

class Player(Base):
    # ... existing fields here ...

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

class Round(Base):
    # ... existing fields here ...

    @classmethod
    def insert_round(cls, game_id, player_id, course_id, round_num, total_score, handicap):
        session = get_db_session()
        round = cls(game_id=game_id, player_id=player_id, course_id=course_id, round_num=round_num, total_score=total_score, handicap=handicap)
        session.add(round)
        session.commit()

    @classmethod
    def previous_rounds(cls, game_id, player_id):
        session = get_db_session()
        rounds = session.query(cls).filter(cls.game_id == game_id, cls.player_id == player_id).order_by(cls.round_num.desc()).all()
        session.close()
        return rounds

class Course(Base):
    # ... existing fields here ...

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

class GamePlayer(Base):
    # ... existing fields here ...

    @classmethod
    def add_player_to_game(cls, game_id, player_id):
        session = get_db_session()
        game_player = cls(game_id=game_id, player_id=player_id)
        session.add(game_player)
        session.commit()
