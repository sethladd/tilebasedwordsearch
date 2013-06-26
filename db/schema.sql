CREATE TABLE IF NOT EXISTS game (
  id SERIAL,
  board VARCHAR(255),
  p1_score INT,
  p2_score INT,
  p1_id INT,
  p2_id INT,
  p1_words TEXT,
  p2_words TEXT,
  last_played TIMESTAMP
);

DROP TABLE IF NOT EXISTS game;

CREATE TABLE IF NOT EXISTS player (
  id SERIAL,
  gplus_id VARCHAR(255) UNIQUE
);