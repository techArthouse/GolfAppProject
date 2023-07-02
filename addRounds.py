import requests
import random

# Define the base URL of your API
base_url = 'http://localhost:5001'

# Game and player IDs
game_id = 4
player_ids = [6]  # Adjust player IDs as needed

# Number of rounds and score range
num_rounds = 10
score_min = 33
score_max = 37

# Add rounds for each player
for player_id in player_ids:
    for round_num in range(1, num_rounds + 1):
        # Generate a random score within the defined range
        total_score = random.randint(score_min, score_max)

        # Prepare the payload for the round creation
        payload = {
            'game_id': game_id,
            'player_id': player_id,
            'course_id': 1,  # Adjust the course ID as needed
            'round_num': round_num,
            'total_score': total_score,
            'handicap': 0.0  # Assuming the initial handicap is 0
        }

        # Send a POST request to the /round endpoint
        response = requests.post(f'{base_url}/round', json=payload)

        if response.status_code == 201:
            print(f"Round added for player {player_id}, round number {round_num}")
        else:
            print(f"Failed to add round for player {player_id}, round number {round_num}")

