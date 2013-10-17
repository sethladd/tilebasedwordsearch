part of wordherd;

class Board {
  final String tiles;
  final List<String> words;
  final List<int> letterBonusTileIndexes;
  final int wordBonusTileIndex;
  
  Game game;
  
  Board(this.game, this.tiles, this.words, this.letterBonusTileIndexes, this.wordBonusTileIndex);

  bool attemptPath(List<int> path) {
    if (path == null) {
      // Invalid path.
      return false;
    }
    String word = stringFromPath(path);
    if (word == '') {
      // Empty word.
      return false;
    }
    if (game.foundWord(word)) {
      // Duplicate word.
      return false;
    }
    if (!words.contains(word)) {
      // Invalid word.
      return false;
    }
    _acceptPath(path, word);
    return true;
  }

  void _acceptPath(List<int> path, String word) {
    int wordScore = scoreForPath(path);
    game.scoreWord(word, wordScore);
  }

  String wordForPath(List<int> path) {
    if (path == null || path.length == 0) {
      return '';
    }
    String r = '';
    for (int i = 0; i < path.length; i++) {
      int index = path[i];
      int row = GameConstants.rowFromIndex(index);
      int column = GameConstants.columnFromIndex(index);
      String tileCharacter = getChar(row, column);
      r += tileCharacter;
      if (tileCharacter == 'Q') {
        r += 'U';
      }
    }
    return r;
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
      String tileCharacter = getChar(row, column);
      int letterScore = GameConstants.letterScores[tileCharacter];
      if (letterBonusTileIndexes.contains(index)) {
        letterScore *= game.scoreMultiplier;
      }
      if (wordBonusTileIndex == index) {
        wordMultiplier = true;
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
      score *= game.scoreMultiplier;
    }
    return score;
  }
  
  String getChar(int i, int j) {
    int index = i * 4 + j;
    return tiles[index];
  }
  
  bool stringInGrid(String search, Set<List<int>> paths) {
    List<String> tileStrings = GameConstants.convertStringToTileList(search);
    // Not there.
    if (tileStrings.length == 0) {
      return false;
    }
    if (paths == null) {
      paths = new Set<List<int>>();
    }
    bool r = false;
    for (int i = 0; i < GameConstants.BoardDimension; i++) {
      for (int j = 0; j < GameConstants.BoardDimension; j++) {
        bool v = _findInGridAt(i, j, tileStrings, paths);
        r = r || v;
      }
    }
    return r;
  }
  
  String stringFromPath(List<int> path) {
    String s = '';
    for (int i = 0; i < path.length; i++) {
      int row = GameConstants.rowFromIndex(path[i]);
      int column = GameConstants.columnFromIndex(path[i]);
      String ch = getChar(row, column);
      s += ch;
    }
    return s;
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
    if (getChar(i,j) != tiles[index]) {
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
    r = _findInGridWorker(tiles, index+1, i-1, j-1, visited, path, paths) || r;
    r = _findInGridWorker(tiles, index+1, i-1, j, visited, path, paths) || r;
    r = _findInGridWorker(tiles, index+1, i-1, j+1, visited, path, paths) || r;
    // Right side.
    r = _findInGridWorker(tiles, index+1, i+1, j-1, visited, path, paths) || r;
    r = _findInGridWorker(tiles, index+1, i+1, j, visited, path, paths) || r;
    r = _findInGridWorker(tiles, index+1, i+1, j+1, visited, path, paths) || r;
    // Top and bottom.
    r = _findInGridWorker(tiles, index+1, i, j-1, visited, path, paths) || r;
    r = _findInGridWorker(tiles, index+1, i, j+1, visited, path, paths) || r;
    visited[i][j] = false;
    path.removeLast();
    return r;
  }

  bool _findInGridAt(int i, int j, List<String> tiles, Set<List<int>> paths) {
    var visited =
        new List.generate(GameConstants.BoardDimension,
                          (_) => new List<bool>(GameConstants.BoardDimension));
    for (int i = 0; i < GameConstants.BoardDimension; i++) {
      for (int j = 0; j < GameConstants.BoardDimension; j++) {
        visited[i][j] = false;
      }
    }
    return _findInGridWorker(tiles, 0, i, j, visited, [], paths);
  }
}
