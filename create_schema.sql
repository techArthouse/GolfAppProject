-- -- Create the User table
-- CREATE TABLE User (
--     user_id INT PRIMARY KEY AUTO_INCREMENT,
--     sub VARCHAR(255) UNIQUE,
--     email VARCHAR(255) UNIQUE
-- );

-- -- Create the Player table
-- CREATE TABLE Player (
--     player_id INT AUTO_INCREMENT PRIMARY KEY,
--     player_name VARCHAR(255),
--     user_id INT UNIQUE,
--     FOREIGN KEY (user_id) REFERENCES User(user_id)
-- );

-- -- Create the Game table
-- CREATE TABLE Game (
--     game_id INT AUTO_INCREMENT PRIMARY KEY,
--     game_name VARCHAR(255),
--     tournament_flag INT,
--     buy_in DECIMAL(10, 2),
--     num_rounds INT,
--     host_id INT,
--     FOREIGN KEY (host_id) REFERENCES Player(player_id)
-- );


-- -- Create the Course table
-- CREATE TABLE Course (
--     course_id INT PRIMARY KEY,
--     course_name VARCHAR(255),
--     course_rating DECIMAL(10, 2),
--     slope_rating INT,
--     par INT
-- );

-- -- Create the Round table
-- CREATE TABLE Round (
--     round_id INT AUTO_INCREMENT PRIMARY KEY,
--     game_id INT,
--     player_id INT,
--     course_id INT,
--     round_num INT,
--     total_score INT,
--     handicap DECIMAL(10, 2),
--     FOREIGN KEY (game_id) REFERENCES Game(game_id),
--     FOREIGN KEY (player_id) REFERENCES Player(player_id),
--     FOREIGN KEY (course_id) REFERENCES Course(course_id)
-- );


-- -- Create the GamePlayer table
-- CREATE TABLE GamePlayer (
--     game_id INT,
--     player_id INT,
--     PRIMARY KEY (game_id, player_id),
--     FOREIGN KEY (game_id) REFERENCES Game(game_id),
--     FOREIGN KEY (player_id) REFERENCES Player(player_id)
-- );

-- -- Create the fullgamedata view
-- CREATE VIEW fullgamedata AS
-- SELECT g.game_id, g.tournament_flag, g.buy_in, g.num_rounds, p.player_id, p.player_name, r.round_id, r.course_id, c.course_name, r.round_num, r.total_score, r.handicap
-- FROM Game g
-- JOIN GamePlayer gp ON g.game_id = gp.game_id
-- JOIN Player p ON gp.player_id = p.player_id
-- JOIN Round r ON g.game_id = r.game_id AND p.player_id = r.player_id
-- JOIN Course c ON r.course_id = c.course_id;


-- CREATE VIEW RoundNumbered AS
-- SELECT 
--     ROW_NUMBER() OVER(PARTITION BY game_id, player_id ORDER BY round_id) as round_num,
--     round_id,
--     game_id,
--     player_id,
--     course_id,
--     total_score,
--     handicap
-- FROM 
--     Round;



-- CREATE VIEW PlayerDetails AS
-- SELECT p.player_id, u.sub, u.email
-- FROM Player p
-- JOIN User u ON p.user_id = u.user_id;


-- DROP PROCEDURE IF EXISTS GetPlayersWithRoundInfo; 

-- DELIMITER //

-- CREATE PROCEDURE GetPlayersWithRoundInfo(IN p_game_id INT)
-- BEGIN
--     DECLARE max_rounds INT;
--     SET max_rounds = (SELECT num_rounds FROM Game WHERE game_id = p_game_id);

--     SELECT
--         p.player_name,
--         COALESCE(r.round_id, NULL) AS round_id,
--         COALESCE(r.round_num, nums.num) AS round_num,
--         COALESCE(r.total_score, NULL) AS total_score,
--         COALESCE(r.handicap, NULL) AS handicap,
--         p.player_id
--     FROM
--         (SELECT DISTINCT player_id FROM GamePlayer WHERE game_id = p_game_id) gp
--     CROSS JOIN
--         (SELECT num FROM (SELECT 1 AS num UNION ALL SELECT 2 UNION ALL SELECT 3) nums WHERE num <= max_rounds) nums
--     LEFT JOIN
--         Round r ON gp.player_id = r.player_id AND nums.num = r.round_num AND r.game_id = p_game_id
--     INNER JOIN
--         Player p ON p.player_id = gp.player_id
--     ORDER BY
--         p.player_id, nums.num;
-- END //

-- DELIMITER ;



-- DROP PROCEDURE IF EXISTS GetPlayerGames; 

-- DELIMITER //

-- CREATE PROCEDURE GetPlayerGames(IN p_playerId INT)
-- BEGIN
--     SELECT
--         g.game_name,
--         (SELECT COUNT(DISTINCT player_id) FROM GamePlayer WHERE game_id = g.game_id) AS num_players,
--         COUNT(DISTINCT r.round_id) AS rounds_completed,
--         g.num_rounds AS total_rounds,
--         g.buy_in AS buy_in,
--         g.game_id
--     FROM
--         Game g
--     LEFT JOIN
--         Round r ON g.game_id = r.game_id AND r.player_id = p_playerId
--     WHERE
--         EXISTS (SELECT 1 FROM GamePlayer WHERE game_id = g.game_id AND player_id = p_playerId)
--     GROUP BY
--         g.game_id;
-- END //

-- DELIMITER ;

