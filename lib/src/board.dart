part of tilebasedwordsearch;

@observable
class Board {
  static const NUM_RECENT_WORDS = 10;
  // TODO make into linkedlist
  final List<String> recentWords = toObservable(new List<String>());
  final Map<String, int> words = new Map<String, int>();
  final BoardConfig config;
  int scoreMultiplier = 1;
  final Set<int> letterBonusTileIndexes = new Set<int>();
  int wordBonusTileIndex = null;

  // TODO: create a Turn to keep the score
  int score = 0;

  Board(this.config);

  Board.fromGame(this.config, Game game) {
    score = game.score;
    words.addAll(game.words);
    recentWords.addAll(game.recentWords);
  }

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
    while (recentWords.length >= NUM_RECENT_WORDS) {
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
