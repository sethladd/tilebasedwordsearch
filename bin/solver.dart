library solver;

import 'dart:math';
import 'dart:io';

List<List> nextMoves = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]];
Map words = new Map();
List<List> grid;
List<List> visited = new List.generate(4, (_) => new List(4));
Map found = new Map();

solve(int x, int y, [String word = '']) {
  visited[x][y] = true;
  
  String newWord = '${word}${grid[x][y]}';
  
  if (words.containsKey(newWord)) {
    found[newWord] = true;
  }
  
  for (var nextMove in nextMoves) {
    var nX = x + nextMove[0];
    var nY = y + nextMove[1];
    if (nX < 0 || nX > 3) continue;
    if (nY < 0 || nY > 3) continue;
    if (visited[nX][nY]) continue;
    solve(nX, nY, newWord);
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