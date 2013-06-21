part of tilebasedwordsearch;

@observable
class Board extends Observable  {
  static const NumRecentWords = 10;
  final List<String> recentWords = toObservable(new List<String>());
  final Map<String, int> words = new Map<String, int>();
  final BoardConfig config;
  int __$scoreMultiplier = 1;
  int get scoreMultiplier {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'scoreMultiplier');
    }
    return __$scoreMultiplier;
  }
  set scoreMultiplier(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'scoreMultiplier',
          __$scoreMultiplier, value);
    }
    __$scoreMultiplier = value;
  }
  final Set<int> letterBonusTileIndexes = new Set<int>();
  int __$wordBonusTileIndex = null;
  int get wordBonusTileIndex {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'wordBonusTileIndex');
    }
    return __$wordBonusTileIndex;
  }
  set wordBonusTileIndex(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'wordBonusTileIndex',
          __$wordBonusTileIndex, value);
    }
    __$wordBonusTileIndex = value;
  }

  // TODO: create a Turn to keep the score
  int __$score = 0;
  int get score {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'score');
    }
    return __$score;
  }
  set score(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'score',
          __$score, value);
    }
    __$score = value;
  }

  Board(this.config);
  
  String get tiles => config.board;

  bool attemptPath(List<int> path) {
    if (path == null) {
      // Invalid path.
      return false;
    }
    String word = config.stringFromPath(path);
    if (word == '') {
      // Empty word.
      return false;
    }
    if (words[word] != null) {
      // Duplicate word.
      return false;
    }
    if (!config.hasWord(word)) {
      // Invalid word.
      return false;
    }
    _acceptPath(path, word);
    return true;
  }

  void _acceptPath(List<int> path, String word) {
    int wordScore = scoreForPath(path);
    score += wordScore;
    while (recentWords.length >= NumRecentWords) {
      recentWords.removeLast();
    }
    recentWords.insert(0, word);
    words[word] = wordScore;
  }

  int scoreForPath(List<int> path) {
    if (path == null || path.length == 0) {
      return 0;
    }
    List<int> scores = new List<int>(path.length);
    bool wordMultiplier = false;
    for (int i = 0; i < path.length; i++) {
      int index = path[i];
      int row = GameConstants.rowFromIndex(index);
      int column = GameConstants.columnFromIndex(index);
      String tileCharacter = config.getChar(row, column);
      int letterScore = GameConstants.letterScores[tileCharacter];
      if (letterBonusTileIndexes.contains(index)) {
        letterScore *= scoreMultiplier;
      }
      scores[i] = letterScore;
    }
    int score = 0;
    for (int i = 0; i < scores.length; i++) {
      score += scores[i];
    }
    // Length bonus.
    if (path.length <= 3) {
      score += 0;
    } else if (path.length <= 4) {
      score += 1;
    } else if (path.length <= 5) {
      score += 2;
    } else if (path.length <= 6) {
      score += 3;
    } else if (path.length <= 7) {
      score += 5;
    } else {
      // 8 or more!
      score += 11;
    }
    // Word bonus.
    if (wordMultiplier) {
      score *= scoreMultiplier;
    }
    return score;
  }
}

//# sourceMappingURL=board.dart.map