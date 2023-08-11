# game_service.py
from models import Game, Player

def create_game(game_data):
    return Game.insert_game(game_data)

def retrieve_game(game_id):
    return Game.get_game(game_id)

def retrieve_game_players(game_id):
    return Game.get_game_players(game_id)

def retrieve_game_rounds(game_id):
    return Game.get_game_rounds(game_id)

# ... this should be modified to get the host of the game and not simply retrieve player ...

def get_game_host(game_id):
    game = retrieve_game(game_id)
    host_id = game.host_id
    host = Player.get_player(host_id).to_dict()
    return host

def create_new_game(game_name, num_rounds, deadline, tournament_flag, buy_in,  host_id):
    try:
        # Create a new game
        game = Game(game_name=game_name, num_rounds=num_rounds, deadline=deadline,
                    host_id=host_id, tournament_flag=tournament_flag, buy_in=buy_in)
        # Insert the game into the database
        game_id = Game.create_new_game(game)
        # Return the game_id and a 200 status code
        return game_id, 200
    except Exception as e:
        # If an error occurred, return the error message and a 400 status code
        return str(e), 400

