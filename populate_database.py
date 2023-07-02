from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Game, Round, Player, Course, GamePlayer, Base

DATABASE_URL = "mysql+pymysql://root:in@localhost/GiovannisGolfScores"

def get_db_session():
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()
    return session

def populate_db():
    session = get_db_session()

    # Database setup
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    # Drop all tables in the database and create new ones
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    
    # Create some Players
    player1 = Player(player_id=1, player_name='Player1')
    player2 = Player(player_id=2, player_name='Player2')
    session.add_all([player1, player2])
    
    # Create a Course
    course = Course(course_id=1, course_name='Course1', course_rating=72.5, slope_rating=130, par=72)
    session.add(course)
    
    # Create a Game
    game = Game(game_id=1, tournament_flag=1, buy_in=50.0, num_rounds=2)
    session.add(game)
    
    # Associate Players with Game
    game_player1 = GamePlayer(game_id=game.game_id, player_id=player1.player_id)
    game_player2 = GamePlayer(game_id=game.game_id, player_id=player2.player_id)
    session.add_all([game_player1, game_player2])
    
    # Create some Rounds
    round1 = Round(round_id=1, game_id=game.game_id, player_id=player1.player_id, course_id=course.course_id, round_num=1, total_score=75, handicap=10.0)
    round2 = Round(round_id=2, game_id=game.game_id, player_id=player2.player_id, course_id=course.course_id, round_num=1, total_score=78, handicap=12.0)
    session.add_all([round1, round2])
    
    session.commit()
    
if __name__ == "__main__":
    populate_db()
