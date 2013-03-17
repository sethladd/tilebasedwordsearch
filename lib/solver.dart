library solver;

import 'dart:math';

class Solver {
  final Map _words;
  final List<List<String>> _grid;
  final List<List> _visited = new List.generate(4, (_) => new List.filled(4, false));
  final Map _found = new Map();
  
  Solver(this._words, this._grid);
  
  _solve(int x, int y, [String word = '']) {
    _visited[x][y] = true;
    
    final newWord = '${word}${_grid[x][y]}';
    
    if (_words.containsKey(newWord)) {
      _found[newWord] = true;
    }
    
    for (var _x = -1; _x < 2; _x++) {
      final nX = x + _x;
      if (nX < 0 || nX > 3) continue;
      for (var _y = -1; _y < 2; _y++) {
        if (_x == 0 && _y == 0) continue;
        final nY = y + _y;
        if (nY < 0 || nY > 3) continue;
        if (_visited[nX][nY] == true) continue;
        _solve(nX, nY, newWord);
      }
    }
    
    _visited[x][y] = false;
  }
  
  Iterable<String> findAll() {
    for (var x = 0; x < 4; x++) {
      for (var y = 0; y < 4; y++) {
        _solve(x, y);
      }
    }
    
    return _found.keys;
  }
}





