part of wordherd_shared;

/// Represents a game, with a score and other
/// data that indicates a play session.
class Game extends ObservableBase with Persistable {
  final Map<String, int> words = toObservable(new LinkedHashMap());
  @observable int score = 0;
  static const int scoreMultiplier = 3;
  Board board;
  
  void scoreWord(String word, int wordScore) {
    score += wordScore;
    words[word] = wordScore;
  }
  
  bool foundWord(String word) => words.containsKey(word);
}