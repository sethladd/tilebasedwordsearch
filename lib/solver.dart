library solver;

import 'package:wordherd/trie.dart' show Trie;
export 'package:wordherd/trie.dart' show Trie;

class Solver {
  final Trie _words;
  final List<List<String>> _grid;
  final List<List> _visited = new List.generate(4, (_) => new List.filled(4, false));
  final List _found = new List();
  
  Solver(this._words, this._grid);
  
  _solve(int x, int y, Trie inProgress) {
    
    final Trie nextStep = inProgress.nodeFor(_grid[x][y]);
    
    if (nextStep != null) {
      if (nextStep.value != null) {
        // FIXME: add real word
        _found.add(nextStep.value);
      }

      _visited[x][y] = true;
      
      for (var _x = -1; _x < 2; _x++) {
        final nX = x + _x;
        if (nX < 0 || nX > 3) continue;
        for (var _y = -1; _y < 2; _y++) {
          if (_x == 0 && _y == 0) continue;
          final nY = y + _y;
          if (nY < 0 || nY > 3) continue;
          if (_visited[nX][nY] == true) continue;
          _solve(nX, nY, nextStep);
        }
      }

      _visited[x][y] = false;
    }
    
  }
  
  Iterable<String> findAll() {
    for (var x = 0; x < 4; x++) {
      for (var y = 0; y < 4; y++) {
        _solve(x, y, _words);
      }
    }
    
    return _found;
  }
}
