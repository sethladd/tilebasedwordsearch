library solver;

import 'dart:math';

Map _words;
List<List<String>> _grid;
final List<List> _visited = new List.generate(4, (_) => new List.filled(4, false));
final Map _found = new Map();

_solve(int x, int y, [String word = '']) {
  _visited[x][y] = true;
  
  String newWord = '${word}${_grid[x][y]}';
  
  if (_words.containsKey(newWord)) {
    _found[newWord] = true;
  }
  
  for (var _x = -1; _x < 2; _x++) {
    var nX = x + _x;
    if (nX < 0 || nX > 3) continue;
    for (var _y = -1; _y < 2; _y++) {
      if (_x == 0 && _y == 0) continue;
      var nY = y + _y;
      if (nY < 0 || nY > 3) continue;
      if (_visited[nX][nY] == true) continue;
      _solve(nX, nY, newWord);
    }
  }
  
  _visited[x][y] = false;
}

Iterable<String> findAll(List<List<String>> grid, Map words) {
  _grid = grid;
  _words = words;
  
  for (var x = 0; x < 4; x++) {
    for (var y = 0; y < 4; y++) {
      _solve(x, y);
    }
  }
  
  return _found.keys;
}