import 'package:tilebasedwordsearch/solver.dart';
import 'dart:io';

List<String> readFile(String path) {
  return new File(path).readAsLinesSync();
}

Trie buildTrie(List<String> lines) {
  Trie words = new Trie();
  for (int i = 0; i < lines.length; i++) {
    var word = lines[i];
    words[word] = word;
  }
  return words;
}

void solveBoard(Trie words, List<List<String>> grid) {
  var solver = new Solver(words, grid);
  List<String> results = solver.findAll().toList();
}

main() {
  const List<List<String>> grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  final Directory pwd = new File(new Options().script).directorySync();
  final String path = '${pwd.path}/../web/assets/dictionary.txt';

  // Warmup.
  for (int i = 0; i < 5; i++) {
    List<String> lines = readFile(path);
    Trie words = buildTrie(lines);
    solveBoard(words, grid);
  }
  print('***** warmup over');
  var sw = new Stopwatch();
  sw.start();
  List<String> lines = readFile(path);
  sw.stop();
  print('Reading file into List took ${sw.elapsedMilliseconds} ms');
  sw.reset();
  sw.start();
  Trie words = buildTrie(lines);
  sw.stop();
  print('Building Trie took ${sw.elapsedMilliseconds} ms');
  sw.reset();
  sw.start();
  solveBoard(words, grid);
  sw.stop();
  print('Solving board took ${sw.elapsedMilliseconds} ms');
}