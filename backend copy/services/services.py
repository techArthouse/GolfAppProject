from db import get_db_session
from sqlalchemy import text
from google.oauth2 import id_token
from google.auth.transport import requests as grequest
from settings import CLIENT_ID
from models import Course

def get_game_players_service(game_id):
    try:
        players = get_game_players(game_id)
        return jsonify(players), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def get_player_games_service(player_id):
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

def exchange_code_service(code):
    try:
        server_auth_code = code

        # Verify the ID token
        idinfo = id_token.verify_oauth2_token(
            server_auth_code,
            grequest.Request(),
            CLIENT_ID
        )

        return idinfo, 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def get_course_service(course_id):
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
        }, 200

def insert_course_service(course_data):
    session = get_db_session()
    course = Course(
        course_name=course_data['course_name'],
        course_rating=course_data['course_rating'],
        slope_rating=course_data['slope_rating'],
        par=course_data['par']
    )
    session.add(course)
    session.commit()
    return {'course_id': course.course_id}, 201
