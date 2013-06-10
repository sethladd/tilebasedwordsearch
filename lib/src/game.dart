part of shared;

class Game extends Object with Persistable {
  String board1;
  String board2;
  String board3;
  DateTime lastPlayed;
  
  Game();
  
  Game.fromPersistance(Map map) {
    board1 = map['board1'];
    board2 = map['board2'];
    board3 = map['board3'];
    lastPlayed = map['lastPlayed'];
  }
  
  Map toMap() {
    return {
      'id': dbId,
      'board1': board1,
      'board2': board2,
      'board3': board3,
      'lastPlayed': lastPlayed
    };
  }
}