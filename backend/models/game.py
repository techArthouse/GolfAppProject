# game.py
from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey
from sqlalchemy.dialects.mysql import DATETIME
from sqlalchemy.orm import relationship
from db import get_db_session
from models.round import Round
from models.game_player import GamePlayer
from . import Base


class Game(Base):
    __tablename__ = 'Game'

    game_id = Column(Integer, primary_key=True, autoincrement=True)
    game_name = Column(String(255))
    tournament_flag = Column(Integer)
    buy_in = Column(DECIMAL(10, 2))
    num_rounds = Column(Integer)
    host_id = Column(Integer, ForeignKey('Player.player_id'))
    deadline = Column(DATETIME)

    rounds = relationship(Round, back_populates="game")
    game_players = relationship(GamePlayer, back_populates="game")

    def __init__(self, game_name, tournament_flag, buy_in, num_rounds, host_id, deadline):
        self.game_name = game_name
        self.tournament_flag = tournament_flag
        self.buy_in = buy_in
        self.num_rounds = num_rounds
        self.host_id = host_id
        self.deadline = deadline

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

    @classmethod
    def create_new_game(cls, game_obj):
    	try:
    		session = get_db_session()
    		session.add(game_obj)
    		session.commit()
    		return game_obj.game_id
    	except Exception as e:
    		session.rollback()
    		raise e