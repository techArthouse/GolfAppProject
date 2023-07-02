from flask import Blueprint, request, jsonify
from backend.services import insert_player, get_player, add_player_to_game, get_player_games

player_bp = Blueprint('player', __name__)

@player_bp.route('/player', methods=['POST'])
def post_player():
    player_data = request.get_json()
    insert_player(player_data)
    return jsonify({'message': 'Player inserted successfully'}), 201

@player_bp.route('/player', methods=['GET'])
def get_player_info():
    player_id = request.args.get('player_id')
    player = get_player(player_id)
    if player is None:
        return jsonify({'error': 'Player not found'}), 404
    return player, 200

@player_bp.route('/gameplayer', methods=['POST'])
def post_game_player():
    data = request.get_json()
    add_player_to_game(data)
    return jsonify({'message': 'Player successfully added to game'}), 201

@player_bp.route('/playergames/<int:player_id>', methods=['GET'])
def get_player_game_info(player_id):
    games = get_player_games(player_id)
    return jsonify(games), 200
