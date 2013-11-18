import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:wordherd/solver.dart' show Solver, Trie;
import 'dart:io';
import 'package:path/path.dart' show dirname;

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

class SolverBenchmark extends BenchmarkBase {
  final List<List<String>> grid;
  final Trie words;
  
  const SolverBenchmark(this.words, this.grid) : super("SolverBenchmark");

  // The benchmark code.
  void run() {
    solveBoard(words, grid);
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

main() {
  const List<List<String>> grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  final String pwd = dirname(Platform.script.toString());
  final String path = '${pwd}/dictionary.txt';

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
  
  new SolverBenchmark(words, grid).report();
  
}