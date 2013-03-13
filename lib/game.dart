library game;

import 'dictionary.dart';

class Game {
  int score;
  Dictionary dictionary;
  List<String> words = <String>[];
  
  Game(this.dictionary);
  
  bool attemptWord(String word) {
    if (_wordIsValid(word)) {
      score += word.length;
      words.add(word);
    }
  }
  
  bool _wordIsValid(String word) => dictionary.hasWord(word);
}