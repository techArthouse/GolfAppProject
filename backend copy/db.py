from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from settings import DATABASE_URL

def get_db_session():
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()
    return session
