part of shared;

class Game extends Object with Persistable {
  String board;
  int score;
  int timeRemaining;
  Map<String, int> words = <String, int>{};
  List<String> recentWords = <String>[];
  List<int> letterBonusTiles = new List<int>();
  int wordBonusTile;

  // See bug 11448. This needs to be a double.
  double lastPlayedMillisSinceEpoch;

  Game();

  Game.fromPersistence(String id, Map data) {
    dbId = id;
    board = data['board'];
    score = data['score'];
    words = data['words'];
    timeRemaining = data['timeRemaining'];
    recentWords = data['recentWords'];
    lastPlayedMillisSinceEpoch = data['lastPlayedMillisSinceEpoch'];
    letterBonusTiles = data['letterBonusTiles'];
    wordBonusTile = data['wordBonusTile'];
  }

  DateTime get lastPlayed {
    return new DateTime.fromMillisecondsSinceEpoch(lastPlayedMillisSinceEpoch.toInt());
  }

  String get lastPlayedFormatted {
    var formatter = new DateFormat("M/d, h:mm a");
    return formatter.format(lastPlayed);
  }

  void set lastPlayed(DateTime timestamp) {
    lastPlayedMillisSinceEpoch = timestamp.millisecondsSinceEpoch.toDouble();
  }

  bool get done => timeRemaining == null || timeRemaining <= 0;

  bool get started => timeRemaining != null;

  Map toJson() {
    return {
      'board': board,
      'score': score,
      'timeRemaining': timeRemaining,
      'words': words,
      'lastPlayedMillisSinceEpoch': lastPlayedMillisSinceEpoch,
      'dbId': dbId,
      'letterBonusTiles': letterBonusTiles,
      'wordBonusTile': wordBonusTile,
      'recentWords': recentWords
    };
  }
}