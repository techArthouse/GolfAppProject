# game_controller.py
from flask import Blueprint, request, jsonify
from services.game_service import create_new_game, get_game_host

game_bp = Blueprint('game', __name__)

@game_bp.route('/game', methods=['POST'])
def post_game():
    game_data = request.get_json()
    new_game, status_code = create_new_game(game_data["name"], game_data["num_rounds"], game_data["deadline"], game_data["is_tournament"], game_data["buy_in"], game_data["host_id"])
    return jsonify({'game_id': new_game}), status_code

@game_bp.route('/game/<int:game_id>/host', methods=['GET'])
def get_game_host_id(game_id):
    host_id = get_game_host(game_id)
    if host_id is None:
        return jsonify({'error': 'Game not found'}), 404
    return jsonify({'host_id': host_id}), 200
