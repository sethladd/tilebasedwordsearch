CREATE TABLE IF NOT EXISTS game (
  id SERIAL,
  board1 VARCHAR(255),
  board2 VARCHAR(255),
  board3 VARCHAR(255),
  player1Score INT,
  player2Score INT,
  lastPlayed TIMESTAMP
);