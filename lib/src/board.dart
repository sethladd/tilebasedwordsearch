part of tilebasedwordsearch;

@observable
class Board {

  static const DIMENSIONS = 4;

  Set<String> words = new Set<String>();
  final List<int> letterBonusTiles = new List<int>(3);

  final BoardAndWords boardAndWords;

  List selectedPositions = [];
  int multiplier = 1;
  int wordBonusTile;

  // TODO: create a Turn to keep the score
  int score = 0;

  GameClock gameClock;

  Board(this.boardAndWords, gameLoop) {
    gameClock = new GameClock(gameLoop);
  }

  String get currentWord {
    return selectedPositions.join('');
  }


  void stop() {
    gameClock.stop();
  }

  List<String> convertStringToTileString(String str) {
    List<String> tileString = [];
    for (int i = 0; i < str.length; i++) {
      if ((str[i] == 'Q' && i+1 >= str.length) ||
          (str[i] == 'Q' && str[i+1] != 'U')) {
        // Q must always be followed by a U.
        return [];
      }
      if (str[i] == 'Q') {
        tileString.add('QU');
        i++;
      } else {
        tileString.add(str[i]);
      }
    }
    return tileString;
  }

  bool _findInGridWorker(List<String> tiles, int index, int i, int j,
                         List<List<bool>> visited, List<int> path,
                         Set<List<int>> paths) {
    // Do bounds check.
    if (i < 0 || j < 0 || i >= 4 || j >= 4) {
      return false;
    }
    if (visited[i][j] == true) {
      return false;
    }
    if (boardAndWords.getChar(i,j) != tiles[index]) {
      return false;
    }
    path.add(i*4+j);
    if (tiles.length == index+1) {
      // Valid.
      paths.add(new List.from(path));
      path.removeLast();
      return true;
    }
    visited[i][j] = true;
    // DFS.
    bool r = false;
    // Left side.
    r = r || _findInGridWorker(tiles, index+1, i-1, j-1, visited, path, paths);
    r = r || _findInGridWorker(tiles, index+1, i-1, j, visited, path, paths);
    r = r || _findInGridWorker(tiles, index+1, i-1, j+1, visited, path, paths);
    // Right side.
    r = r || _findInGridWorker(tiles, index+1, i+1, j-1, visited, path, paths);
    r = r || _findInGridWorker(tiles, index+1, i+1, j, visited, path, paths);
    r = r || _findInGridWorker(tiles, index+1, i+1, j+1, visited, path, paths);
    // Top and bottom.
    r = r || _findInGridWorker(tiles, index+1, i, j-1, visited, path, paths);
    r = r || _findInGridWorker(tiles, index+1, i, j+1, visited, path, paths);
    visited[i][j] = false;
    path.removeLast();
    return r;
  }

  bool _findInGridAt(int i, int j, List<String> tiles, Set<List<int>> paths) {
    var visited = new List.generate(4, (_) => new List<bool>(4));
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        visited[i][j] = false;
      }
    }
    return _findInGridWorker(tiles, 0, i, j, visited, [], paths);
  }

  bool stringInGrid(String search, Set<List<int>> paths) {
    List<String> tileStrings = convertStringToTileString(search);
    // Not there.
    if (tileStrings.length == 0) {
      return false;
    }
    if (paths == null) {
      paths = new Set<List<int>>();
    }
    bool r = false;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        bool v = _findInGridAt(i, j, tileStrings, paths);
        r = r || v;
      }
    }
    return r;
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
    return convertStringToTileString(word)
        .map((char) => TileSet.LETTER_SCORES[char])
        .toList()
        .reduce((value, element) => value + element);
  }

  Future get done {
    return gameClock.allDone.future;
  }

  bool _wordIsValid(String word) => boardAndWords.hasWord(word);
}
