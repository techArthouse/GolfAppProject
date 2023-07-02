# course.py
from sqlalchemy import Column, Integer, String, DECIMAL
from sqlalchemy.orm import relationship
from db import get_db_session
from models.round import Round
from . import Base


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
