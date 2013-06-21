part of shared;

class Game extends Object with Persistable {
  String board;
  int score;
  int timeRemaining;
  List<String> words = <String>[];
  int lastPlayedMillisSinceEpoch;
  
  Game();
  
  DateTime get lastPlayed => new DateTime.fromMillisecondsSinceEpoch(lastPlayedMillisSinceEpoch);
  void set lastPlayed(DateTime timestamp) {
    lastPlayedMillisSinceEpoch = timestamp.millisecondsSinceEpoch;
  }
  
  Map toJson() {
    return {
      'board': board,
      'score': score,
      'timeRemaining': timeRemaining,
      'words': words,
      'lastPlayedMillisSinceEpoch': lastPlayedMillisSinceEpoch
    };
  }
}