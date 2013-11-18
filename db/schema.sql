DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS gamematch;
DROP TABLE IF EXISTS twoplayermatch;

CREATE TABLE IF NOT EXISTS gamematch (
  id SERIAL,
  p1_id VARCHAR(255),
  p2_id VARCHAR(255),
  p1_name VARCHAR(255),
  p2_name VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  board TEXT,
  p1_game TEXT,
  p2_game TEXT
);

CREATE INDEX ON gamematch (p1_id);
CREATE INDEX ON gamematch (p2_id);

CREATE TABLE IF NOT EXISTS player (
  id SERIAL,
  gplus_id VARCHAR(255) UNIQUE,
  name VARCHAR(255)
);

INSERT INTO player (gplus_id, name) VALUES ('100399120809275930649', 'Kathy Walrath');