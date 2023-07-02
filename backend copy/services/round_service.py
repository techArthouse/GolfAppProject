from backend.models import insert_round, previous_rounds

def create_round(round_data):
    return insert_round(round_data)

def retrieve_previous_rounds(player_id, game_id):
    return previous_rounds(player_id, game_id)
