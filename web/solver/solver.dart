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
  
  Trie words = new Trie();
  
  HttpRequest.getString("../assets/dictionary.txt")
    .then((contents) {
      contents.split("\n").forEach((line) => words[line] = line);
      //numWords.text = '${words.length}';
      
      var solver = new Solver(words, grid);
      
      var sw = new Stopwatch()..start();
      List<String> results = solver.findAll().toList();
      sw.stop();
      
      resultsWords.text = '$results';
      resultsLength.text = '${results.length}';
      time.text = 'Found in ${sw.elapsedMilliseconds} ms';
    })
    .catchError((e) => print(e));
}
