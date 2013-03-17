import 'dart:html';
import 'package:tilebasedwordsearch/solver.dart';

main() {
  var numWords = query('#num-words');
  var resultsWords = query('#results-words');
  var resultsLength = query('#results-length');
  var time = query('#time');
  
  const List<List<String>> grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  
  Map words = new Map();
  
  HttpRequest.getString("assets/dictionary.txt")
    .then((contents) {
      contents.split("\n").forEach((line) => words[line] = true);
      numWords.text = '${words.length}';
      
      var sw = new Stopwatch()..start();
      List<String> results = findAll(grid, words).toList();
      sw.stop();
      
      resultsWords.text = '$results';
      resultsLength.text = '${results.length}';
      time.text = 'Found in ${sw.elapsedMilliseconds} ms';
    })
    .catchError((e) => print(e));
}
