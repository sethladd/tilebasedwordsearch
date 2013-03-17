import 'package:tilebasedwordsearch/solver.dart';
import 'dart:io';

main() {
  const List<List<String>> grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  
  Map words = new Map();
  Directory pwd = new File(new Options().script).directorySync();
  new File('${pwd.path}/../web/assets/dictionary.txt')
      .readAsLinesSync()
      .forEach((line) => words[line] = true);
  print(words.length);
  
  var solver = new Solver(words, grid);
  
  var sw = new Stopwatch()..start();
  List<String> results = solver.findAll().toList();
  sw.stop();
  
  print(results);
  print(results.length);
  print('Found in ${sw.elapsedMilliseconds} ms');
}