# game_player.py
from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from db import get_db_session
from . import Base



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

    @classmethod
    def add_players_to_game(cls, game_id, players):
    	for player in players:
    		cls.add_player_to_game(game_id, player.player_id)