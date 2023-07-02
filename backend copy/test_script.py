from services import get_game_players_service

def test_get_game_players_service():
    game_id = 1  # replace with an actual game_id in your database
    result = get_game_players_service(game_id)
    print(result)

if __name__ == "__main__":
    test_get_game_players_service()
