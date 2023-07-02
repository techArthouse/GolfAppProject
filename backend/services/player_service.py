# player_service.py
from models import Player

def create_player(player_data):
    return Player.insert_player(player_data)

def retrieve_player(player_id):
    return Player.get_player(player_id)

def assign_player_to_game(data):
    return Player.add_player_to_game(data)

def retrieve_player_games(player_id):
    return Player.get_player_games(player_id)

def add_players_to_game(emails, game_id):
    try:
        return Player.add_players_to_game(emails, game_id)
    except Exception as e:
        return str(e), 400