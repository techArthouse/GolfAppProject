import sqlite3
import random
import csv

def load_data():
    with open('GolfData.csv', 'r') as f:
        reader = csv.reader(f)
        data = [row for row in reader]

    return data

def create_database(data):
    con = sqlite3.connect("golf.db")
    cur = con.cursor()

    cur.execute("""
    CREATE TABLE IF NOT EXISTS Game (
        game_id INTEGER PRIMARY KEY,
        tournament_flag INTEGER,
        buy_in REAL,
        num_rounds INTEGER
    );
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS Player (
        player_id INTEGER PRIMARY KEY,
        player_name TEXT
    );
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS Course (
        course_id INTEGER PRIMARY KEY,
        course_name TEXT,
        course_rating REAL,
        slope_rating REAL,
        par INTEGER
    );
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS Round (
        round_id INTEGER PRIMARY KEY,
        game_id INTEGER,
        player_id INTEGER,
        course_id INTEGER,
        round_num INTEGER,
        total_score INTEGER,
        avg_handicap REAL,
        FOREIGN KEY(game_id) REFERENCES Game(game_id),
        FOREIGN KEY(player_id) REFERENCES Player(player_id),
        FOREIGN KEY(course_id) REFERENCES Course(course_id)
    );
    """)

    max_games = 20
    max_players = 10
    max_courses = 5

    for i in range(1, max_games + 1):
        cur.execute("INSERT INTO Game VALUES (?, ?, ?, ?)",
                    (i, random.randint(0, 1), random.uniform(50, 200), random.randint(1, 9)))

    for i in range(1, max_players + 1):
        cur.execute("INSERT INTO Player VALUES (?, ?)",
                    (i, 'Player' + str(i)))

    for i in range(1, max_courses + 1):
        cur.execute("INSERT INTO Course VALUES (?, ?, ?, ?, ?)",
                    (i, 'Course' + str(i), random.uniform(30, 40), random.randint(50, 60), random.randint(30, 40)))

    for row in data[1:]:
        player_id, round_id, game_id, round_num, course_id, total_score = row

        cur.execute("INSERT INTO Round (round_id, game_id, player_id, course_id, round_num, total_score) VALUES (?, ?, ?, ?, ?, ?)", (round_id, game_id, player_id, course_id, round_num, total_score))

    con.commit()
    con.close()

def main():
    data = load_data()
    create_database(data)

if __name__ == "__main__":
    main()
