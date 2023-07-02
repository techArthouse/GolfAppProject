import random

# Number of players, games, and courses
NUM_PLAYERS = 10
NUM_GAMES = 5
NUM_COURSES = 10
MAX_HOLES = 9

# Distribute score across holes
def distribute_score(score, holes=9):
    scores = [0] * holes
    for _ in range(score):
        scores[random.randint(0, holes - 1)] += 1
    return scores

# Theme park names for course names
COURSE_NAMES = [
    'Magic Kingdom', 'Epcot', 'Hollywood Studios', 'Animal Kingdom',
    'Universal Studios', 'Islands of Adventure', 'Volcano Bay',
    'SeaWorld', 'Busch Gardens', 'Legoland'
]

# Player IDs range from 1 to NUM_PLAYERS (inclusive)
player_ids = list(range(1, NUM_PLAYERS + 1))
# Game IDs range from 1 to NUM_GAMES (inclusive)
game_ids = list(range(1, NUM_GAMES + 1))

# Generate rounds per game
rounds_per_game = {game_id: random.randint(1, MAX_HOLES + 1) for game_id in game_ids}

# Generate players
print("-- Insert players into Player")
for player_id in player_ids:
    player_name = f"Player{player_id}"
    share_rounds = 1 if player_id <= 10 else 0
    print(f"INSERT INTO Player (player_name, share_rounds) VALUES ('{player_name}', {share_rounds});")

# Generate games
print("\n-- Insert games into Game")
for game_id in game_ids:
    tournament_flag = 1 if game_id <= 2 else 0
    buy_in = random.randint(0, 500) if tournament_flag == 1 else 0
    filtered_rounds = {game: num_rounds for game, num_rounds in rounds_per_game.items() if game == game_id}
    num_rounds = filtered_rounds.get(game_id)
    print(f"INSERT INTO Game (tournament_flag, buy_in, num_rounds) VALUES ({tournament_flag}, {buy_in}, {num_rounds});")

# Generate courses
print("\n-- Insert courses into Course")
for i in range(NUM_COURSES):
    course_name = COURSE_NAMES[i]
    course_rating = round(random.uniform(30, 37), 1)
    slope_rating = random.randint(45, 60)
    par = random.randint(32, 38)
    print(f"INSERT INTO Course (course_name, course_rating, slope_rating, par) VALUES ('{course_name}', {course_rating}, {slope_rating}, {par});")

# Generate rounds data
rounds = []  # List to store the generated rounds
global_round_id = 0  # New variable for generating globally unique round_id
for game_id, round_count in rounds_per_game.items():
    for player_id in player_ids:
        for round_num in range(1, round_count + 1):
            course_id = random.randint(1, NUM_COURSES)
            global_round_id += 1  # Increment the globally unique round_id
            rounds.append((global_round_id, game_id, player_id, course_id))


# Generate rounds and scores
print("\n-- Insert rounds into Round and scores into Score")
handicap_scores = {game_id: {player_id: [] for player_id in player_ids} for game_id in game_ids}  # to store the scores used for handicap calculation
handicaps_calculated = {game_id: {player_id: set() for player_id in player_ids} for game_id in game_ids}  # to store rounds for which handicap was calculated
raw_scores = {}  # Dictionary to store raw scores for each round
game_scores = {player_id: {game_id: 0 for game_id in game_ids} for player_id in player_ids}
handicap_id = 1  # Initialize handicap_id

for round_id, game_id, player_id, course_id in rounds:
    agg_score = random.randint(45, 80)
    raw_scores[(game_id, player_id, round_id)] = agg_score
    game_scores[player_id][game_id] += agg_score

    print(f"INSERT INTO Round (game_id, player_id, round_num, course_id, raw_score) VALUES ({game_id}, {player_id}, {round_id}, {course_id}, {agg_score});")
    
    # Insert scores for each hole
    hole_scores = distribute_score(agg_score)
    for hole_num, hole_score in enumerate(hole_scores, start=1):
        print(f"INSERT INTO Score (round_id, player_id, hole_number, hole_score) VALUES ({round_id}, {player_id}, {hole_num}, {hole_score});")
    
    handicap_scores[game_id][player_id].append(agg_score)
    if round_id not in handicaps_calculated[game_id][player_id]:  # if handicap for the round was not yet calculated
        handicap = round((sum(handicap_scores[game_id][player_id]) / len(handicap_scores[game_id][player_id]) - 35) * 113 / 55, 1)  # calculation based on USGA handicap formula
        print(f"INSERT INTO Handicap (handicap_id, player_id, round_id, handicap) VALUES ({handicap_id}, {player_id}, {round_id}, {handicap});")
        handicaps_calculated[game_id][player_id].add(round_id)  # remember that handicap for the round was calculated
        handicap_id += 1  # Increment handicap_id

# # Generate trending handicaps
#     sql_file.write("\n-- Insert trending handicaps into TrendingHandicap\n")
#     for player_id in player_ids:
#         trending_handicap = random.randint(0, 36)
#         sql_file.write(f"INSERT INTO TrendingHandicap (player_id, trending_handicap) VALUES ({player_id}, {trending_handicap});\n")
