import json
import pymysql
from flask import Flask, request, jsonify
from sqlalchemy import create_engine
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker
from models import Game, Round, Player, Course, GamePlayer, Base, User
import requests
from google.oauth2 import id_token
from google.auth.transport import requests as grequest

app = Flask(__name__)

NUMBER_OF_HOLES = 18
DATABASE_URL = "mysql+pymysql://root:in@localhost/GiovannisGolfScores"

def get_db_session():
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()
    return session

@app.route('/course', methods=['GET', 'POST'])
def course():
    if request.method == 'POST':
        return insert_course()
    elif request.method == 'GET':
        return get_course()

def get_course():
    course_id = request.args.get('course_id')
    session = get_db_session()
    course = session.query(Course).get(course_id)

    if course is None:
        return 'Course not found', 404
    else:
        return {
            'course_id': course.course_id,
            'course_name': course.course_name,
            'course_rating': course.course_rating,
            'slope_rating': course.slope_rating,
            'par': course.par
        }


def get_game_players(game_id):
    session = get_db_session()
    result = session.execute(
        text('CALL GetPlayersWithRoundInfo(:game_id)'),
        {'game_id': game_id}
    )
    session.commit()
    # Extract required columns from the result set
    players = [
        {
            'player_name': row[0],
            'round_id': row[1],
            'round_num': row[2],
            'total_score': row[3],
            'handicap': row[4],
            'player_id': row[5]
        }
        for row in result
    ]
    return players



@app.route('/gameplayers/<int:game_id>', methods=['GET'])
def get_players_with_round_info(game_id):
    try:
        players = get_game_players(game_id)
        return jsonify(players), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/playergames/<int:player_id>', methods=['GET'])
def get_player_games(player_id):
    try:
        session = get_db_session()
        result = session.execute(
            text('CALL GetPlayerGames(:player_id)'),
            {'player_id': player_id}
        )
        session.commit()

        games = [
            {
                'game_name': row[0],
                'num_players': row[1],
                'rounds_completed': row[2],
                'total_rounds': row[3],
                'buy_in': row[4],
                'game_id': row[5]
            }
            for row in result
        ]

        return jsonify(games), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/exchange', methods=['POST'])
def exchange_code():
    try:
        server_auth_code = request.json['code']
        client_id = '66603309185-k7bccilod9b8pqfk87ngdssgv6ep1da8.apps.googleusercontent.com'

        # Verify the ID token
        idinfo = id_token.verify_oauth2_token(server_auth_code, grequest.Request(), client_id)

        # Extract user information from the ID token
        sub = idinfo['sub']
        email = idinfo['email']

        session = get_db_session()

        # Check if the user already exists in the database
        user = session.query(User).filter_by(sub=sub).first()

        if user is None:
            # User doesn't exist, create a new user record
            user = User(sub=sub, email=email)
            session.add(user)
            session.commit()

            # Create a new player for the user with a handicap of 0
            player = Player(player_name=email, handicap=0)
            player.user = user  # Assign the user to the player
            session.add(player)
            session.commit()

        # Retrieve the player associated with the user
        player = session.query(Player).filter_by(player_id=user.user_id).first()

        if player is None:
            return jsonify({'error': 'Player not found'}), 404

        # Return a success response with player_id included
        return jsonify({'message': 'Code exchange successful', 'error': '', 'player_id': player.player_id, 'host_id': player.player_id})

    except ValueError as e:
        return jsonify({'message': '', 'error': str(e)}), 400
    except Exception as e:
        return jsonify({'message': '', 'error': str(e)}), 500



@app.route('/game', methods=['POST'])
def create_game():
    try:
        game_data = request.get_json()
        name = game_data['name']
        buy_in = game_data['buy_in']
        tournament_flag = 0
        num_rounds = game_data['num_rounds']
        host_id = game_data['host_id']  # New: Get the host ID from the request

        session = get_db_session()
        new_game = Game(game_name=name, tournament_flag=tournament_flag, buy_in=buy_in, num_rounds=num_rounds, host_id=host_id)  # Updated: Include the host ID
        session.add(new_game)
        session.commit()
        session.flush()

        # Add the player who created the game to the game itself
        new_gameplayer = GamePlayer(game_id=new_game.game_id, player_id=host_id)  # Updated: Use the host ID
        session.add(new_gameplayer)

        session.commit()

        return jsonify({'game_id': new_game.game_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@app.route('/game/<int:game_id>/host', methods=['GET'])
def get_game_host(game_id):
    try:
        session = get_db_session()
        game = session.query(Game).get(game_id)

        if game is None:
            return jsonify({'error': 'Game not found'}), 404

        host_id = game.host_id
        return jsonify({'message': 'found host', 'error': '','host_id': host_id}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 400


@app.route('/gameplayer', methods=['POST'])
def add_player_to_game():
    data = request.get_json()
    game_id = data['game_id']
    player_id = data['player_id']
    session = get_db_session()
    new_gameplayer = GamePlayer(game_id=game_id, player_id=player_id)
    session.add(new_gameplayer)
    session.commit()
    return jsonify({'message': 'Player successfully added to game'}), 201



def get_host_id(game_id):
    session = get_db_session()
    game = session.query(Game).get(game_id)
    if game is not None:
        return game.host_id
    return None


@app.route('/player', methods=['POST'])
def insert_player():
    data = request.get_json()
    session = get_db_session()

    new_player = Player(player_id=data['player_id'], player_name=data['player_name'])
    session.add(new_player)
    session.commit()

    return 'Player inserted successfully'

@app.route('/course', methods=['POST'])
def insert_course():
    data = request.get_json()
    session = get_db_session()

    new_course = Course(course_id=data['course_id'], course_name=data['course_name'], course_rating=data['course_rating'], slope_rating=data['slope_rating'], par=data['par'])
    session.add(new_course)
    session.commit()

    return 'Course inserted successfully'


@app.route('/previous_rounds', methods=['GET'])
def previous_rounds():
    player_id = request.args.get('player_id')
    game_id = request.args.get('game_id')

    session = get_db_session()
    previous_scores = session.query(Round.total_score).filter(
        Round.player_id == player_id,
        Round.game_id == game_id
    ).order_by(Round.round_num).all()

    if previous_scores is None:
        return {'previous_scores': []}
    else:
        return {'previous_scores': [score[0] for score in previous_scores]}


def previous_roundss(player_id, game_id):
    # player_id = request.args.get('player_id')
    # game_id = request.args.get('game_id')

    session = get_db_session()
    previous_scores = session.query(Round.total_score).filter(
        Round.player_id == player_id,
        Round.game_id == game_id
    ).order_by(Round.round_num).all()

    if previous_scores is None:
        return {'previous_scores': []}
    else:
        return {'previous_scores': [score[0] for score in previous_scores]}



def calculate_trending_handicap(previous_scores, current_handicap, course_type):
    num_previous_rounds = len(previous_scores)

    if num_previous_rounds == 0:
        return round(5, 1)

    if num_previous_rounds == 1:
        return round((5 + previous_scores[0]) / 2, 1)

    if num_previous_rounds == 2:
        return round((5 + previous_scores[0] + previous_scores[1]) / 3, 1)

    if num_previous_rounds == 3:
        return round((previous_scores[0] + previous_scores[1] + previous_scores[2]) / 3, 1)

    best_scores = sorted(previous_scores)[:3]
    average_score = sum(best_scores) / 3

    if course_type == 9:  # If the course is 9 holes, halve the scores in relation to par
        average_score /= 2

    if current_handicap == 5:
        return round(average_score, 1)
    else:
        return round(average_score, 1)




@app.route('/round', methods=['POST'])
def insert_round():
    try:
        data = request.get_json()

        game_id = data['game_id']
        player_id = data['player_id']
        course_id = data['course_id']
        round_num = data['round_num']
        total_score = data['total_score']
        handicap = data['handicap']

        session = get_db_session()

        # print(f"wtf {player_id}, round number {game_id}")
        # Calculate the trending handicap for the player
        player = session.query(Player).get(player_id)
        previous_scores = previous_roundss(player_id, game_id)  # Retrieve previous rounds' scores
        trending_handicap = calculate_trending_handicap(previous_scores['previous_scores'], player.handicap, 9)  # Calculate trending handicap
        player.handicap = trending_handicap  # Update player's handicap

        # Get the auto-incremented round_id from the database
        result = session.execute(text('INSERT INTO Round (game_id, player_id, course_id, round_num, total_score, handicap) VALUES (:game_id, :player_id, :course_id, :round_num, :total_score, :handicap)'), {
            'game_id': game_id,
            'player_id': player_id,
            'course_id': course_id,
            'round_num': round_num,
            'total_score': total_score,
            'handicap': trending_handicap
        })

        # Retrieve the round_id of the newly inserted round
        round_id = result.lastrowid

        session.commit()
        return jsonify({'round_id': round_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 400



@app.route('/player', methods=['GET'])
def get_player():
    player_id = request.args.get('player_id')
    session = get_db_session()
    player = session.query(Player).get(player_id)

    if player is None:
        return 'Player not found', 404
    else:
        return {
            'player_id': player.player_id,
            'player_name': player.player_name,
        }



@app.route('/fullgamedata', methods=['GET'])
def full_game_data():
    session = get_db_session()
    result = session.execute(text('SELECT * FROM fullgamedata'))
    session.commit()
    result_list = [row._asdict() for row in result]
    return jsonify(result_list)



if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=True)

