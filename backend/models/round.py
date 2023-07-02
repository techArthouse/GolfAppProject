# round.py
from sqlalchemy import Column, Integer, ForeignKey, DECIMAL
from sqlalchemy.orm import relationship
from db import get_db_session
from . import Base



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
