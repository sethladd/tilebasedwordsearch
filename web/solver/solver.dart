import 'dart:html' show HttpRequest, querySelector, window;
import 'package:wordherd/solver.dart' show Solver;
import 'package:wordherd/trie.dart' show Trie;

main() {
  var timeToParseFiles = querySelector("#time-to-parse-file");
  var numWords = querySelector('#num-words');
  var resultsWords = querySelector('#results-words');
  var resultsLength = querySelector('#results-length');
  var time = querySelector('#time');
  
  const List<List<String>> grid = const [
    const ['A', 'B', 'C', 'D'],
    const ['E', 'F', 'G', 'H'],
    const ['I', 'J', 'K', 'L'],
    const ['M', 'N', 'O', 'P']
  ];
  
  // HIGH SCORING BOARD
//  const List<List<String>> grid = const [
//const ['S', 'E', 'R', 'S'],
//const ['P', 'A', 'T', 'G'],
//const ['L', 'I', 'N', 'E',],
//const ['S', 'E', 'R', 'S']                                       
//];
  
  Trie words = new Trie();
  
  HttpRequest.getString("../assets/dictionary.txt")
    .then((contents) {
      
      var start = window.performance.now();
      contents.split("\n").forEach((line) => words[line] = line);
      var stop = window.performance.now();
      
      var readFilesTime = stop - start;
      
      //numWords.text = '${words.length}';
      
      var solver = new Solver(words, grid);
      
      start = window.performance.now();
      List<String> results = solver.findAll().toList();
      stop = window.performance.now();
      
      var findAllTime = stop - start;
      
      timeToParseFiles.text = '$readFilesTime';
      resultsWords.text = '$results';
      resultsLength.text = '${results.length}';
      time.text = 'Found in $findAllTime ms';
    })
    .catchError((e) => print(e));
}
