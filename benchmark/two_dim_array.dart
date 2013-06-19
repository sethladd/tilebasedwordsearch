// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';

// Create a new benchmark by extending BenchmarkBase
class TwoDimArray extends BenchmarkBase {
  static const List<List<String>> grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  
  const TwoDimArray() : super("TwoDimArray");

  static void main() {
    new TwoDimArray().report();
  }

  // The benchmark code.
  void run() {
    var x = grid[2][3];
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

class OneDimArray extends BenchmarkBase {
  final List<List<String>> grid =
      const ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
             'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];
  
  final xDim = 4;
  final yDim = 4;
  
  const OneDimArray() : super("OneDimArray");

  static void main() {
    new OneDimArray().report();
  }

  // The benchmark code.
  void run() {
    var x = grid[2 * xDim + 3];
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

main() {
  // Run TemplateBenchmark
  TwoDimArray.main();
  OneDimArray.main();
}

