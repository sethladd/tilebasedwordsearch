DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS match;
DROP TABLE IF EXISTS twoplayermatch;

CREATE TABLE IF NOT EXISTS match (
  id SERIAL,
  p1_id VARCHAR(255),
  p2_id VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS player (
  id SERIAL,
  gplus_id VARCHAR(255) UNIQUE,
  name VARCHAR(255)
);

CREATE INDEX ON match (p1_id);
CREATE INDEX ON match (p2_id);

CREATE TABLE IF NOT EXISTS twoplayermatch (
  id SERIAL,
  board VARCHAR(255),
  word_bonus_tile INT,
  letter_bonus_tile_indexes VARCHAR(255),
  created_on TIMESTAMP,
  p1_id VARCHAR(255),
  p2_id VARCHAR(255),
  p1_name VARCHAR(255),
  p2_name VARCHAR(255),
  p1_words TEXT,
  p2_words TEXT,
  p1_score INT,
  p2_score INT,
  p1_played TIMESTAMP,
  p2_played TIMESTAMP
);

CREATE INDEX ON twoplayermatch (p1_id);
CREATE INDEX ON twoplayermatch (p2_id);