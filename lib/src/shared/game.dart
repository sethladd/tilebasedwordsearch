part of shared;

class Game extends Object with Persistable {
  String board;
  int score;
  int timeRemaining;
  Map<String, int> words = <String, int>{};
  List<String> recentWords = <String>[];

  // See bug 11448. This needs to be a double.
  double lastPlayedMillisSinceEpoch;

  Game();

  DateTime get lastPlayed {
    return new DateTime.fromMillisecondsSinceEpoch(lastPlayedMillisSinceEpoch.toInt());
  }

  String get lastPlayedFormatted {
    var formatter = new DateFormat("M/d, h:m a");
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
      'recentWords': recentWords
    };
  }
}