library game;

import 'dictionary.dart';

class Game {
  int score;
  Dictionary dictionary;
  
  Game(this.dictionary);
  
  bool attemptWord(String word) {
    if (_wordIsValid(word)) {
      score += word.length;
    }
  }
  
  bool _wordIsValid(String word) => dictionary.hasWord(word);
}