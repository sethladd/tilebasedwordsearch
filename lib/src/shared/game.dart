part of wordherd_shared;

/// Represents a game, with a score and other
/// data that indicates a play session.
class Game extends Object with Observable {
  Map<String, int> words = toObservable(new LinkedHashMap());
  @observable int score = 0;
  @observable bool isStarted = false;
  @observable bool isDone = false;
  static const int scoreMultiplier = 3;
  
  void scoreWord(String word, int wordScore) {
    // TODO play a sound if the word was already found?
    if (!words.containsKey(word) || words[word] < wordScore) {
      words[word] = wordScore;
      score = words.values.reduce((v, e) => v + e);
    }
  }
  
  bool previouslyFoundWord(String word) => words.containsKey(word);
  
  String toString() => 'score: $score, isStarted: $isStarted, isDone: $isDone';
}