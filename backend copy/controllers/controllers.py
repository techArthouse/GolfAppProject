from flask import Blueprint, request, jsonify
from services import get_game_players_service, get_player_games_service, exchange_code_service, get_course_service, insert_course_service

gameplayers_controller = Blueprint('gameplayers', __name__)
playergames_controller = Blueprint('playergames', __name__)
exchange_controller = Blueprint('exchange', __name__)
course_controller = Blueprint('course', __name__)

@gameplayers_controller.route('/<int:game_id>', methods=['GET'])
def get_players_with_round_info(game_id):
    return get_game_players_service(game_id)

@playergames_controller.route('/<int:player_id>', methods=['GET'])
def get_player_games(player_id):
    return get_player_games_service(player_id)

@exchange_controller.route('/', methods=['POST'])
def exchange_code():
    return exchange_code_service(request.json['code'])

@course_controller.route('/', methods=['GET', 'POST'])
def course():
    if request.method == 'POST':
        return insert_course_service(request.json)
    elif request.method == 'GET':
        return get_course_service(request.args.get('course_id'))
