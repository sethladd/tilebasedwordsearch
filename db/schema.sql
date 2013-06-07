CREATE TABLE IF NOT EXISTS games (
  id SERIAL,
  board VARCHAR(255),
  last_played TIMESTAMP
);