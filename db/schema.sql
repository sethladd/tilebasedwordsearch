DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS match;

CREATE TABLE IF NOT EXISTS player (
  id SERIAL,
  gplus_id VARCHAR(255) UNIQUE,
  name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS twoplayermatch (
  id SERIAL,
  board VARCHAR(255),
  created_on TIMESTAMP,
  p1_id VARCHAR(255),
  p2_id VARCHAR(255),
  p1_words TEXT,
  p2_words TEXT,
  p1_score INT,
  p2_score INT,
  p1_played TIMESTAMP,
  p2_played TIMESTAMP
);

CREATE INDEX ON twoplayermatch (p1_id);
CREATE INDEX ON twoplayermatch (p2_id);