part of shared;

class Game extends Object with Persistable {
  String board;
  int score;
  int timeRemaining;
  List<String> words = <String>[];
  DateTime lastPlayed = new DateTime.now();
  
  Game();
  
  Map toJson() {
    return {
      'board': board,
      'score': score,
      'timeRemaining': timeRemaining,
      'words': words,
      'lastPlayed': lastPlayed
    };
  }
}