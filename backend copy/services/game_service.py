from backend.models import insert_game, get_game, get_game_players, get_game_rounds

def create_game(game_data):
    return insert_game(game_data)

def retrieve_game(game_id):
    return get_game(game_id)

def retrieve_game_players(game_id):
    return get_game_players(game_id)

def retrieve_game_rounds(game_id):
    return get_game_rounds(game_id)
