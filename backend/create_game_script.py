# create_game_script.py
from services.game_service import create_new_game
from services.player_service import add_players_to_game
from datetime import datetime

# User inputs game name
game_name = input('Please input a name for the game: ')

# User inputs number of rounds
num_rounds = int(input('Please input the number of rounds: '))

# User inputs deadline for the game
deadline = input('Please input the deadline for the game (YYYY-MM-DD): ')
# Convert deadline to datetime object
deadline = datetime.strptime(deadline, '%Y-%m-%d')

# User inputs whether the game is a tournament
tournament_flag = input("Is this game a tournament? Enter 'yes' or 'no': ")
tournament_flag = 1 if tournament_flag.lower() == 'yes' else 0

# User inputs the buy-in amount
buy_in = float(input("If there's a buy-in for the game, how much is it? If none, enter 0: "))

# User inputs host_id
host_id = input('Please input the host id for the game: ')

# Create a new game and get the game_id
game_id, status_code = create_new_game(game_name, num_rounds, deadline, host_id, tournament_flag, buy_in)

if status_code == 200:
    print(f'Game successfully created with id {game_id}')
else:
    print('Failed to create the game:', game_id)
    exit(1)

# User inputs a list of emails
emails = input('Please input the emails of the players (separated by commas): ').split(',')

# Add the players to the game
message, status_code = add_players_to_game(emails, game_id)

if status_code == 200:
    print('Players successfully added to the game')
else:
    print('Failed to add players to the game:', message)
