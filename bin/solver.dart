library solver;

import 'dart:math';
import 'dart:io';

final Map words = new Map();
List<List> grid;
final List<List> visited = new List.generate(4, (_) => new List(4));
final Map found = new Map();

solve(int x, int y, [String word = '']) {
  visited[x][y] = true;
  
  String newWord = '${word}${grid[x][y]}';
  
  if (words.containsKey(newWord)) {
    found[newWord] = true;
  }
  
  for (var _x = -1; _x < 2; _x++) {
    var nX = x + _x;
    if (nX < 0 || nX > 3) continue;
    for (var _y = -1; _y < 2; _y++) {
      if (_x == 0 && _y == 0) continue;
      var nY = y + _y;
      if (nY < 0 || nY > 3) continue;
      if (visited[nX][nY] == true) continue;
      solve(nX, nY, newWord);
    }
  }
  
  visited[x][y] = false;
}

findAll() {
  for (var x = 0; x < 4; x++) {
    for (var y = 0; y < 4; y++) {
      solve(x, y);
    }
  }
  
  print('done!');
}

main() {
  grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  
  Directory pwd = new File(new Options().script).directorySync();
  new File('${pwd.path}/../web/assets/dictionary.txt')
      .readAsLinesSync()
      .forEach((line) => words[line] = true);
  print(words.length);
  
  var sw = new Stopwatch()..start();
  findAll();
  sw.stop();
  
  print(found.keys.toList());
  print('Found in ${sw.elapsedMilliseconds} ms');
}