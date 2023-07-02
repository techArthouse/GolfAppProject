from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, Game, Player, Round, Course, User, GamePlayer
from random import choice, randint

DATABASE_URL = "mysql+pymysql://root:in@localhost/GiovannisGolfScores"

# Define constants
NUM_ROUNDS = 3
NUM_PLAYERS = 5
NUM_COURSES = 5
PLAYER_NAMES = ['Player1', 'Player2', 'Player3', 'Player4', 'Player5']
COURSES = [  # Some dummy courses for the sake of this example
    Course(course_id=1, course_name='Course1', course_rating=65.1, slope_rating=108, par=70),
    Course(course_id=2, course_name='Course2', course_rating=65.1, slope_rating=108, par=70),
    Course(course_id=3, course_name='Course3', course_rating=65.1, slope_rating=108, par=70),
    Course(course_id=4, course_name='Course4', course_rating=65.1, slope_rating=108, par=70),
    Course(course_id=5, course_name='Course5', course_rating=65.1, slope_rating=108, par=70)
]


def add_users(session, num_players):
    # Add users to the database
    users = [
        User(sub=f'sub{i + 1}', email=f'user{i + 1}@example.com') for i in range(num_players)
    ]
    for user in users:
        session.add(user)
    session.commit()


def populate_db():
    # Database setup
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    # Drop all tables in the database and create new ones
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)

    # Add courses
    for course in COURSES:
        session.add(course)
    session.commit()

    # Create a game
    game = Game(game_id=1, game_name='Mini Golf', num_rounds=NUM_ROUNDS)
    session.add(game)
    session.commit()

    # Add users to the database
    add_users(session, NUM_PLAYERS)

    # Retrieve the users from the database
    users = session.query(User).all()

    # Add players to the game
    players = [
        Player(player_id=i + 1, player_name=name, user=users[i], handicap=0) for i, name in enumerate(PLAYER_NAMES[:NUM_PLAYERS])
    ]
    for player in players:
        session.add(player)
    session.commit()

    # Add players to the game
    for player in players:
        game_player = GamePlayer(game_id=game.game_id, player_id=player.player_id)
        session.add(game_player)
    session.commit()

    # Assign round numbers based on completed rounds for each player
    round_count = {}
    for player in players:
        round_count[player.player_id] = 0

    for i in range(NUM_ROUNDS):
        for player in players:
            round_count[player.player_id] += 1
            round_num = round_count[player.player_id]

            if round_num <= game.num_rounds:
                round_id = (i * NUM_PLAYERS * game.num_rounds) + (player.player_id * game.num_rounds) + round_num
                player_round = Round(
                    round_id=round_id,
                    game_id=game.game_id,
                    player_id=player.player_id,
                    course_id=COURSES[i % NUM_COURSES].course_id,
                    round_num=round_num,
                    total_score=randint(32, 38),
                    handicap=0
                )
                session.add(player_round)
    session.commit()


populate_db()
