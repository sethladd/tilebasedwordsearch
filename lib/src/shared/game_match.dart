part of wordherd_shared;

class GameMatch extends Object with Persistable {
  String p1_id;
  String p1_name;
  String p2_id;
  String p2_name;
  @serialized Board board;
  @serialized Game p1_game;
  @serialized Game p2_game;
  DateTime created_at; // set by persistance
  DateTime updated_at;

  String opponentName(String myId) {
    return (p1_id == myId) ? p2_name : p1_name;
  }

  int opponentScore(String myId) {
    return (p1_id == myId) ? p2_game.score : p1_game.score;
  }

  String myName(String myId) {
    return (p1_id == myId) ? p1_name : p2_name;
  }

  int myScore(String myId) {
    return (p1_id == myId) ? p1_game.score : p2_game.score;
  }

  bool myTurnOver(String myId) {
    return (p1_id == myId) ? p1_game.isDone : p2_game.isDone;
  }

  String get winningName {
    if (!isOver) return null;
    return (p1_game.score > p2_game.score) ? p1_name : p2_name;
  }

  String get winningId {
    if (!isOver) return null;
    return (p1_game.score > p2_game.score) ? p1_id : p2_id;
  }

  bool get isOver => p1_game.isDone && p2_game.isDone;

  Game myGame(String playerId) {
    return (p1_id == playerId) ? p1_game : p2_game;
  }

  void updateGameFor(Game game, String playerId) {
    if (p1_id == playerId) {
      p1_game = game;
    } else if (p2_id == playerId) {
      p2_game = game;
    } else {
      throw new ArgumentError('$playerId does not have a game in this match');
    }
  }
}
