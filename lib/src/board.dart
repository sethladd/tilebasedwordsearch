part of tilebasedwordsearch;

@observable
class Board {
  Map<String, int> words = new Map<String, int>();
  final List<int> letterBonusTiles = new List<int>(3);

  final BoardConfig config;

  List selectedPositions = [];
  int multiplier = 1;
  int wordBonusTile;

  // TODO: create a Turn to keep the score
  int score = 0;

  Board(this.config) {
  }

  String get currentWord {
    return selectedPositions.join('');
  }

  bool attemptWord(String word) {
    if (words[word] != null) {
      return false;
    }
    if (_wordIsValid(word)) {
      int wordScore = scoreForWord(word);
      score += wordScore;
      words[word] = wordScore;
      return true;
    }
    return false;
  }

  int scoreForWord(String word) {
    return GameConstants.convertStringToTileList(word)
        .map((char) => GameConstants.letterScores[char])
        .toList()
        .reduce((value, element) => value + element);
  }

  bool _wordIsValid(String word) => config.hasWord(word);
}
