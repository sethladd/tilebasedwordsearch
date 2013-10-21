DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS match;
DROP TABLE IF EXISTS twoplayermatch;

CREATE TABLE IF NOT EXISTS match (
  id SERIAL,
  p1_id VARCHAR(255),
  p2_id VARCHAR(255),
  board TEXT,
  p1_game TEXT,
  p2_game TEXT
);

CREATE TABLE IF NOT EXISTS player (
  id SERIAL,
  gplus_id VARCHAR(255) UNIQUE,
  name VARCHAR(255)
);

CREATE INDEX ON match (p1_id);
CREATE INDEX ON match (p2_id);

INSERT INTO player (gplus_id, name) VALUES ('100399120809275930649', 'Kathy Walrath');