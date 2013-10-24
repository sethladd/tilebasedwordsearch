part of wordherd_shared;

class GameMatch extends Object with Persistable {
  String p1_id;
  String p1_name;
  String p2_id;
  String p2_name;
  @serialized Board board;
  @serialized Game p1_game;
  @serialized Game p2_game;
  DateTime created_at = new DateTime.now(); // TODO persistence should set this
  
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
    return (p1_game.score > p2_game.score) ? p1_name : p2_name;
  }
  
  bool get isOver => p1_game.isDone && p2_game.isDone;
}
