from backend.models import insert_player, get_player, add_player_to_game, get_player_games

def create_player(player_data):
    return insert_player(player_data)

def retrieve_player(player_id):
    return get_player(player_id)

def assign_player_to_game(data):
    return add_player_to_game(data)

def retrieve_player_games(player_id):
    return get_player_games(player_id)
