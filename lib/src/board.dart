part of tilebasedwordsearch;

@observable
class Board {
  Set<String> words = new Set<String>();
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
    if (words.contains(word)) {
      return false;
    }
    if (_wordIsValid(word)) {
      score += scoreForWord(word);
      print('score = $score');
      words.add(word);
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
