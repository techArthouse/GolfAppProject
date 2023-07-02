# round_service.py
from models import Round

def create_round(round_data):
    return Round.insert_round(round_data)

def retrieve_previous_rounds(player_id, game_id):
    return Round.previous_rounds(player_id, game_id)
