library solver;

import 'dart:math';
import 'dart:io';
import 'dart:isolate';
import 'dart:async';

void isolateSolvr() {
  Map words;
  List<List> grid;
  final List<List> visited = new List.generate(4, (_) => new List.filled(4, false));
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
        if (visited[nX][nY]) continue;
        solve(nX, nY, newWord);
      }
    }

    visited[x][y] = false;
  };

  port.receive((msg, SendPort reply) {
      int y = msg['y'];
      int x = msg['x'];
      grid = msg['grid'];
      words = msg['words'];
      solve(x, y);
      reply.call({'found': found});
  });
}

final Map words = new Map();
List<List> grid;
final List<List> visited = new List.generate(4, (_) => new List.filled(4, false));
final Map found = new Map();
Set foundSet = new Set();
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
      if (visited[nX][nY]) continue;
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
// No improvement
//    solve(x, 0);
//    solve(x, 1);
//    solve(x, 2);
//    solve(x, 3);
  }
}

void findAllWithIsolates() {
  List<SendPort> workerPorts = <SendPort>[spawnFunction(isolateSolvr),
                                              spawnFunction(isolateSolvr),
                                              spawnFunction(isolateSolvr),
                                              spawnFunction(isolateSolvr)];
  var swFutures = new Stopwatch()..start();
  List futures = new List();
  for (var x = 0; x < 4; x++) {
// This only provides a 100ms improvement
//    for (var y = 0; y < 4; y++) {
//      futures.add(workerPorts[y].call({'x': x, 'y': y, 'grid': grid, 'words': words})
//          .then((reply) => foundSet.addAll(reply["found"].keys.toList())));
//    }

// unrolling the loop provides a ~2 second improvement
      futures.add(workerPorts[0].call({'x': x, 'y': 0, 'grid': grid, 'words': words})
          .then((reply) => foundSet.addAll(reply["found"].keys.toList())));
      futures.add(workerPorts[1].call({'x': x, 'y': 1, 'grid': grid, 'words': words})
          .then((reply) => foundSet.addAll(reply["found"].keys.toList())));
      futures.add(workerPorts[2].call({'x': x, 'y': 2, 'grid': grid, 'words': words})
          .then((reply) => foundSet.addAll(reply["found"].keys.toList())));
      futures.add(workerPorts[3].call({'x': x, 'y': 3, 'grid': grid, 'words': words})
          .then((reply) => foundSet.addAll(reply["found"].keys.toList())));
  }

  Future.wait(futures).then((f) {
    swFutures.stop();
    print('Isolates Found in ${swFutures.elapsedMilliseconds} ms');
    print(foundSet.toList());
    print('Isolates done!');
  });
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

  findAllWithIsolates();
}