part of shared;

class Boards {

  List<BoardConfig> boards = new List<BoardConfig>();
  Random _rand = new Random();

  Boards(String data) {
    final StringBuffer tiles = new StringBuffer();

    data.split('\n').forEach((String line) {
      if (line.trim().length < 32) return;
      String letters = line.substring(0, 32).split(' ').join('');
      List<String> words = line.substring(33).split(' ');
      boards.add(new BoardConfig(letters, words));
    });
  }

  BoardConfig getRandomBoard() {
    var index = _rand.nextInt(boards.length);
    return boards[index];
  }

}

class BoardConfig {
  final String _board;
  final List<String> _words;

  BoardConfig(this._board, this._words);

  String getChar(int i, int j) {
    int index = i * 4 + j;
    return _board[index];
  }
  
  bool hasWord(String word) => _words.contains(word);

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

}