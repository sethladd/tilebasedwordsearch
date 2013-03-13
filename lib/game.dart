library game;

import 'package:tilebasedwordsearch/dictionary.dart';
import 'package:tilebasedwordsearch/board.dart';

@observable
class Game {
  int score = 0;
  Dictionary dictionary;
  List<String> words = <String>[];
  Board board;
  
  Game(this.dictionary) {
    board = new Board(this);
  }
  
  bool attemptWord(String word) {
    if (_wordIsValid(word)) {
      score += word.length;
      words.add(word);
    }
  }
  
  bool _wordIsValid(String word) => dictionary.hasWord(word);
}