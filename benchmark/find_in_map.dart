// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';

import 'dart:io';
import 'dart:collection';

// Create a new benchmark by extending BenchmarkBase
class FindInMap extends BenchmarkBase {
  final Map words;
  
  const FindInMap(this.words) : super("FindInMap");

  // The benchmark code.
  void run() {
    var x = words.containsKey('PHOSPHITE');
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

class FindInList extends BenchmarkBase {
  final List words;
  
  const FindInList(this.words) : super("FindInList");

  // The benchmark code.
  void run() {
    var x = words.contains('PHOSPHITE');
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

main() {
  List<String> lines = [];
  Map words = new Map();
  
  Directory pwd = new File(new Options().script).directory;
  lines = new File('${pwd.path}/../web/assets/dictionary.txt')
  .readAsLinesSync();
  
  lines.forEach((line) => words[line] = true);
  
  // Run TemplateBenchmark
  new FindInMap(words).report();
  new FindInList(lines).report();
}

