import pandas as pd
import numpy as np

# Load the data
df = pd.read_csv("preOutput.csv")

# Process Player data
players = df[['PLAYER']].drop_duplicates()
players.columns = ['player_name']
players['player_id'] = np.arange(len(players)) + 1

# Process Course data
courses = df[['Course', 'Slope Rating', 'Course Rating', 'Par']].drop_duplicates()
courses.columns = ['course_name', 'slope_rating', 'course_rating', 'par']
courses['course_id'] = np.arange(len(courses)) + 1

# Process Handicap data
handicaps = df[['PLAYER', 'Handicap from this Round']].copy()
handicaps.columns = ['player_name', 'handicap']
handicaps['player_id'] = handicaps.player_name.map(players.set_index('player_name').player_id)
handicaps['round_id'] = np.arange(len(handicaps)) + 1

# Process Game and Round data
games = pd.DataFrame({'game_id': [1], 'tournament_flag': [0], 'buy_in': [0], 'num_rounds': [len(df)]})
rounds = pd.DataFrame({'round_id': np.arange(len(df)) + 1, 'game_id': 1, 'player_id': handicaps.player_id, 'course_id': df.Course.map(courses.set_index('course_name').course_id)})

# Process Score data
scores = pd.DataFrame({'round_id': np.repeat(rounds.round_id, 9), 'hole_number': np.tile(np.arange(1, 10), len(rounds)), 'hole_score': df['Raw Score'].apply(lambda x: x // 9).values.repeat(9)})
scores['score_id'] = np.arange(len(scores)) + 1

# Process TrendingHandicap data
trending_handicaps = df[['PLAYER', 'Handicap']].copy()
trending_handicaps.columns = ['player_name', 'trending_handicap']
trending_handicaps['player_id'] = trending_handicaps.player_name.map(players.set_index('player_name').player_id)

# Save to CSV
players.to_csv('players.csv', index=False)
courses.to_csv('courses.csv', index=False)
games.to_csv('games.csv', index=False)
rounds.to_csv('rounds.csv', index=False)
scores.to_csv('scores.csv', index=False)
handicaps.to_csv('handicaps.csv', index=False)
trending_handicaps.to_csv('trending_handicaps.csv', index=False)

# Merge the datasets
merged = rounds.merge(players, on='player_id').merge(courses, on='course_id').merge(scores, on='round_id').merge(handicaps, on=['player_id', 'round_id']).merge(trending_handicaps, on='player_id').merge(games, on='game_id')

# Save to CSV
merged.to_csv('merged.csv', index=False)
