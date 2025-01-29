-- Twitch Data Analysis SQL Queries
-- This script contains SQL queries for analyzing Twitch gaming data.
-- It includes:
-- 1️ Data inspection & exploration
-- 2️ Aggregations for popular games & streamers
-- 3 Game genre categorization
-- 4 Viewer activity trends over time
-- 5 Subscriber vs. non-subscriber analysis

-- Data Source: Twitch

-- 1 Inspect data tables
-- 🔍 View sample data from the Twitch Chat table
SELECT *
FROM twitch_data.chat
LIMIT 20;

-- 🔍 View sample data from the Twitch stream table
SELECT *
FROM twitch_data.stream
LIMIT 20;

-- Get Unique Games in the Stream Table
-- 🔍 Get a list of unique games streamed on Twitch
SELECT DISTINCT game
FROM twitch_data.stream;

-- 🔍 Count the number of unique devices and logins per game
SELECT 
  game,
  COUNT(DISTINCT device_id),
  COUNT(DISTINCT login)
FROM twitch_data.stream
GROUP BY 1
ORDER BY 3 DESC;

-- Get Unique Channels in the Stream Table
-- 🔍 Get a list of unique Twitch channels
SELECT DISTINCT channel
FROM twitch_data.stream;

-- 🔍 Count unique devices and users per channel
SELECT 
  DISTINCT channel,
  COUNT(DISTINCT device_id),
  COUNT(DISTINCT login)
FROM twitch_data.stream
GROUP BY 1
ORDER BY 2 DESC;

-- 2 Aggregations for popular games & streamers

-- Most Popular Games on Twitch
-- 🔍 Find the most popular games based on stream count and unique logins
SELECT 
  DISTINCT game,
  COUNT(*) AS 'row_count',
  COUNT(DISTINCT login) AS 'unique_login'
FROM twitch_data.stream
GROUP BY 1
ORDER BY 2 DESC;

-- Top 10 Countries Watching League of Legends
-- 🔍 Identify where most League of Legends viewers are located (Top 10 countries)
SELECT 
  game,
  country,
  COUNT(*) AS 'row_count',
  COUNT(DISTINCT device_id) AS 'unique_device',
  COUNT(DISTINCT login) AS 'unique_login'
FROM twitch_data.stream
WHERE game = 'League of Legends'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;

-- Count the Number of Streamers per Player
-- 🔍 List players and the number of streamers they have
SELECT 
  DISTINCT player,
  COUNT(*) AS 'row_count',
  COUNT(DISTINCT login) AS 'unique_login'
FROM twitch_data.stream
GROUP BY 1
ORDER BY 2 DESC;

-- Games Categorized into Genres
-- 🔍 Categorize games into MOBA, FPS, Survival, and Other
SELECT 
  CASE
    WHEN game IN('League of Legends', 'Dota 2', 'Heroes of the Storm') THEN 'MOBA'
    WHEN game IN('Counter-Strike: Global Offensive') THEN 'FPS'
    WHEN game IN('DayZ', 'ARK: Survival Evolved') THEN 'Survival'
    ELSE 'Other'
  END AS 'genre',
  COUNT(*) AS 'row_count',
  COUNT(DISTINCT login) AS 'unique_login'
FROM twitch_data.stream
GROUP BY 1
ORDER BY 3 DESC;

-- After creating a new table in MySQLWorkbench to store game genre
SELECT 
  g.genre,
  COUNT(*) AS 'row_count',
  COUNT(DISTINCT s.login) AS 'unique_login'
FROM twitch_data.stream s
LEFT JOIN twitch_data.game_genre g ON g.game_name = s.game
GROUP BY 1
ORDER BY 3 DESC;

-- 3 Viewer activity trends over time
-- How does view count change in the course of a day?

-- 🔍 Inspect the time column
SELECT time
FROM twitch_data.stream
LIMIT 10;

-- 🔍 Test strftime() function
SELECT 
    time,
    DATE_FORMAT(time, '%S')
FROM twitch_data.stream
GROUP BY 1
LIMIT 20;

-- 🔍 Find peak Twitch viewing hours (US viewers)
-- Helps streamers schedule broadcasts when audience engagement is highest
SELECT 
    DATE_FORMAT(time, '%H') AS 'hour', 
    COUNT(*) AS 'row_count',
    COUNT(DISTINCT login) AS 'unique_login'
FROM twitch_data.stream
WHERE country = 'US'
GROUP BY 1;

-- Join Chat and Stream Tables
-- 🔗 Join chat and stream tables using device_id to analyze user behavior
SELECT *
FROM twitch_data.stream s
JOIN twitch_data.chat c
  ON s.device_id = c.device_id
LIMIT 10;

-- Viewers Analysis for a Specific Game
-- 🔍 Analyze League of Legends viewers by country
SELECT 
  country,
  COUNT(*) AS 'total_streams',
  COUNT(DISTINCT login) AS 'unique_viewers',
  COUNT(DISTINCT device_id) AS 'unique_devices'
FROM twitch_data.stream
WHERE game = 'League of Legends'
GROUP BY 1
ORDER BY unique_viewers DESC
LIMIT 10;

-- 🔍 Most Active Channels Based on Chat Messages
SELECT 
  channel,
  COUNT(*) AS 'total_messages',
  COUNT(DISTINCT login) AS 'unique_users'
FROM twitch_data.chat
WHERE game = 'Dota 2'
GROUP BY 1
ORDER BY total_messages DESC;

-- Most Popular Games in Twitch Chat
-- 🔍 Analyze Twitch Chat Activity for Channels & Games
SELECT
    s.channel,
    s.game, 
    -- Total chat activity
    COUNT(c.login) AS 'total_chat_messages',
    COUNT(DISTINCT c.login) AS 'unique_chat_users',
    -- Subscriber-only chat activity
    COUNT(CASE WHEN s.subscriber = 'True' THEN c.login END) AS 'subscribers_total_chat_messages',
    COUNT(DISTINCT CASE WHEN s.subscriber = 'True' THEN c.login END) AS 'subscribers_unique_chat_users',
    -- Non-subscriber chat activity
    COUNT(CASE WHEN s.subscriber IN('False', '') THEN c.login END) AS 'non_subscribers_total_chat_messages',
    COUNT(DISTINCT CASE WHEN s.subscriber IN('False', '') THEN c.login END) AS 'non_subscribers_unique_chat_users'

FROM twitch_data.stream s
JOIN twitch_data.chat c ON s.device_id = c.device_id
    AND s.channel = c.channel
    AND s.game = c.game
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;

-- Subscriber Activity in Chat
SELECT 
  c.game,
  COUNT(*) AS 'total_chat_messages'
FROM twitch_data.chat c
JOIN twitch_data.stream s ON c.device_id = s.device_id
WHERE s.subscriber = 'True'
GROUP BY c.game, s.subscriber
ORDER BY total_chat_messages DESC;

-- Popular Games Analysis
-- Game Popularity in Streams
SELECT 
  game,
  COUNT(*) AS 'total_streams',
  COUNT(DISTINCT login) AS 'unique_streamers'
FROM twitch_data.stream
GROUP BY game
ORDER BY total_streams DESC
LIMIT 10;

-- Game Popularity in Chat
SELECT 
  game,
  COUNT(*) AS 'total_chat_messages',
  COUNT(DISTINCT login) AS 'unique_chat_users'
FROM twitch_data.chat
GROUP BY game
ORDER BY total_chat_messages DESC
LIMIT 10;

-- Analyze Viewer Overlap Between Games
-- 🔍 Viewers Watching Multiple Games
SELECT 
  s1.game AS 'game1',
  s2.game AS 'game2',
  COUNT(DISTINCT s1.device_id) AS 'shared_viewers'
FROM stream s1
JOIN stream s2 ON s1.device_id = s2.device_id AND s1.game != s2.game
GROUP BY game1, game2
ORDER BY shared_viewers DESC
LIMIT 10;

-- 🔍 Peak Viewing Hours for League of Legends
SELECT 
  DATE_FORMAT(time, '%H') AS 'hour',
  COUNT(*) AS 'total_streams',
  COUNT(DISTINCT login) AS 'unique_viewers'
FROM twitch_data.stream
WHERE game = 'League of Legends'
GROUP BY hour
ORDER BY hour;


--  🔍 Featured Games section listing the “Games people are watching now”. (now being 2015-01-01)
SELECT
    game, 
    COUNT(*) AS 'Viewers'
FROM twitch_data.stream
WHERE time >= '2015-01-01 00:00:00' AND time < '2015-01-02 00:00:00'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
