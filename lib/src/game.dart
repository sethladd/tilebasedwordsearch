part of shared;

class Game extends Object with Persistable {
  String board1;
  String board2;
  String board3;
  
  int p1_b1_score;
  int p1_b2_score;
  int p1_b3_score;
  
  int p2_b1_score;
  int p2_b2_score;
  int p2_b3_score;
  
  int p1_score;
  int p2_score;
  
  DateTime last_played;
  
  Game();
  
  // TODO: replace with mirrors
  Game.fromPersistance(Map map) {
    board1 = map['board1'];
    board2 = map['board2'];
    board3 = map['board3'];
    
    p1_b1_score = map['p1_b1_score'];
    p1_b2_score = map['p1_b2_score'];
    p1_b3_score = map['p1_b3_score'];
    
    p2_b1_score = map['p2_b1_score'];
    p2_b2_score = map['p2_b2_score'];
    p2_b3_score = map['p2_b3_score'];
    
    p1_score = map['p1_score'];
    p2_score = map['p2_score'];
    
    last_played = map['lastPlayed'];
  }
}