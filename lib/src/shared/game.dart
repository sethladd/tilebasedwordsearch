part of wordherd_shared;

/// Represents a game, with a score and other
/// data that indicates a play session.
class Game extends Object with Observable {
  Map<String, int> words = toObservable(new LinkedHashMap());
  @observable int score = 0;
  @observable bool isStarted = false;
  @observable bool isDone = false;
  @observable int timeRemaining = DEFAULT_GAME_LENGTH;

  static const int scoreMultiplier = 3;
  static const int DEFAULT_GAME_LENGTH = 70;

  void scoreWord(String word, int wordScore) {
    // TODO play a sound if the word was already found?
    if (!words.containsKey(word) || words[word] < wordScore) {
      words[word] = wordScore;
      score = words.values.reduce((v, e) => v + e);
    }
  }

  bool previouslyFoundWord(String word) => words.containsKey(word);

  String toString() => 'score: $score, isStarted: $isStarted, isDone: $isDone';

  // This is here to so that mirrorsused keeps words.keys.
  Iterable<String> get justWords => words.keys;
}