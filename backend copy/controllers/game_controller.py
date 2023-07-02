from flask import Blueprint, request, jsonify
from backend.services import create_game, get_game_host

game_bp = Blueprint('game', __name__)

@game_bp.route('/game', methods=['POST'])
def post_game():
    game_data = request.get_json()
    new_game = create_game(game_data)
    return jsonify({'game_id': new_game.game_id}), 201

@game_bp.route('/game/<int:game_id>/host', methods=['GET'])
def get_game_host_id(game_id):
    host_id = get_game_host(game_id)
    if host_id is None:
        return jsonify({'error': 'Game not found'}), 404
    return jsonify({'host_id': host_id}), 200
