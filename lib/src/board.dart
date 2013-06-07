part of tilebasedwordsearch;

@observable
class Board {

  static const DIMENSIONS = 4;

  List<List<String>> grid = new List.generate(4, (_) => new List<String>(4));
  List selectedPositions = [];

  int multiplier = 1;
  final List<int> letterBonusTiles = new List<int>(3);
  int wordBonusTile;

  int score = 0;
  final Dictionary dictionary;
  Set<String> words = new Set<String>();

  GameClock gameClock;

  Board(this.dictionary, gameLoop) {
    _assignCharsToPositions();
    gameClock = new GameClock(gameLoop);
  }

  Board.fromJson(Map json) {

  }

  Map toJson() {
  }

  String get currentWord {
    return selectedPositions.join('');
  }

  void clearSelectedPositions() {
    selectedPositions = [];
  }

  bool addToSelectedPositions(position) {
    if (selectedPositions.isEmpty || this.validMove(selectedPositions.last, position)) {
      selectedPositions.add(position);
      return true;
    }
    return false;
  }

  bool isPositionSelected(position) {
    bool selected = false;
    for (var i = 0; i < selectedPositions.length; i++) {
      if (selectedPositions[i].first == position.first &&
          selectedPositions[i].last == position.last) {
        selected = true;
        break;
      }
    }
    return selected;
  }

  void stop() {
    gameClock.stop();
  }

  void _assignCharsToPositions() {
    int gameId = new Random().nextInt(1000000);
    List<String> selectedLetters = TileSet.getTilesForGame(gameId);
    for (var i = 0; i < DIMENSIONS; i++) {
      for (var j = 0; j < DIMENSIONS; j++) {
        this.grid[i][j] = selectedLetters[i*DIMENSIONS+j];
      }
    }
  }

  // There is no checking that the word has been previously picked or not.
  // All this does is check if every move in a path is legal.
  bool completePathIsValid(path) {
    if (path.length != path.toSet().length) return false;

    var valid = true;
    for (var i = 0; i < path.length - 1; i++) {
      if (!validMove(path[i], path[i + 1])) {
        valid = false;
      }
    }
    return valid;
  }

  // Checks if move from position1 or position2 is legal.
  bool validMove(position1, position2) {
    bool valid = true;

    if (!_vertical(position1, position2) &&
        !_horizontal(position1, position2) &&
        !_diagonal(position1, position2)) {
      valid = false;
    }
    return valid;
  }

  // Args are GameLoopTouchPosition(s).
  bool _vertical(position1, position2) => position1.x == position2.x;

  bool _horizontal(position1, position2) => position1.y == position2.y;

  bool _diagonal(position1, position2) {
    return ((position1.x - position2.y).abs() == 1 &&
        (position1.y - position2.x).abs()) &&
        !(position1.x == position2.x && position1.x == position2.x);
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
    if (grid[i][j] != tiles[index]) {
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
    List<int> scores = convertStringToTileString(word).map(
        (char) => TileSet.LETTER_SCORES[char]).toList();
    return scores.reduce((value, element) => value + element);
  }

  Future get done {
    return gameClock.allDone.future;
  }

  bool _wordIsValid(String word) => dictionary.hasWord(word);
}
