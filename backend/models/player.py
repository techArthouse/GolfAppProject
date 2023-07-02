# player.py
from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey
from sqlalchemy.orm import relationship
from db import get_db_session
from models.game_player import GamePlayer
from models.round import Round
from models.user import User
from . import Base


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
    def insert_player(cls, player_name, user_id, handicap=0):
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

    def to_dict(self):
        return {
            "player_id": self.player_id,
            "player_name": self.player_name,
            "user_id": self.user_id,
            "handicap": self.handicap
        }

    @classmethod
    def add_players_to_game(cls, emails, game_id):
    	from db import get_db_session
    	session = get_db_session()
    	try:
    		players = []
    		for email in emails:
    			# Fetch user by email
    			user = session.query(User).filter_by(email=email).first()

    			# If the user does not exist, create a new user and a player associated with it
    			if not user:
    				user = User(email=email, verified="pending")
    				session.add(user)
    				session.commit()
    				player_name = email.split('@')[0]
    				cls.insert_player(player_name, user.user_id)

    			player = cls.get_player_by_user_id(user.user_id)
    			players.append(player)

    		# Add all players to the game
    		GamePlayer.add_players_to_game(game_id, players)
    		return 'Players successfully added to the game', 200
    	except Exception as e:
    		session.rollback()  # rollback in case of exceptions
    		raise e  # re-raise the exception
    	finally:
    		session.close()  # close session

    @classmethod
    def get_player_by_user_id(cls, user_id):
    	session = get_db_session()
    	player = session.query(cls).filter(cls.user_id == user_id).first()
    	session.close()
    	return player