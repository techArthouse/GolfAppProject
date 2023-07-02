# round_controller.py
from flask import Blueprint, request, jsonify
from services.round_service import create_round #, get_round

round_bp = Blueprint('round', __name__)

@round_bp.route('/round', methods=['POST'])
def post_round():
    round_data = request.get_json()
    round_id = insert_round(round_data)
    return jsonify({'round_id': round_id}), 201

@round_bp.route('/previous_rounds', methods=['GET'])
def get_previous_rounds():
    player_id = request.args.get('player_id')
    game_id = request.args.get('game_id')
    scores = previous_rounds(player_id, game_id)
    return scores, 200


# revisit this again as it's missing some calls