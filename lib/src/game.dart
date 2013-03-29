part of tilebasedwordsearch;

@observable
class Game {
  
  static const DIMENSIONS = 4;
  static const List<String> LETTERS = const ['A', 'B', 'C', 'D', 'E', 'F',
                                             'G', 'H', 'I', 'J', 'I', 'J',
                                             'K', 'L', 'M', 'N', 'O', 'P', 
                                             'QU', 'R', 'S', 'T', 'U', 'V',
                                             'W', 'X', 'Y', 'Z'];
  
  List<List<String>> grid = new List.generate(4, (_) => new List<String>(4));
  int score = 0;
  Dictionary dictionary;
  List<String> words = <String>[];

  CanvasElement canvas;

  BoardView board;
  
  Completer whenDone = new Completer();
  
  Game(this.dictionary, this.canvas) {
    _assignCharsToTiles();
    board = new BoardView(this, canvas);
  }
  
  void _assignCharsToTiles() {
    Random random = new Random();
    for (var i = 0; i < DIMENSIONS; i++) {
      for (var j = 0; j < DIMENSIONS; j++) {
        this.grid[i][j] = LETTERS[random.nextInt(LETTERS.length)];
      }
    }
  }
  
  // There is no checking that the word has been previously picked or not.
  // All this does is check if every move in a path is legal.
  bool completePathIsValid(path) {
    var valid = true;
    for (var i = 0; i < path.length - 1; i++) {
      if (!validMove(path[i], path[i + 1])) {
        valid = false;
      }
    }
    return valid;
  }
  
  // Checks if move from position1 or position2 is legal.
  bool validMove(position1, position2) {
    bool valid = true;
    
    if (!_vertical(position1, position2) && 
        !_horizontal(position1, position2) &&
        !_diagonal(position1, position2)) {
      valid = false;
    }
    return valid;
  }

  // Args are GameLoopTouchPosition(s).
  bool _vertical(position1, position2) => position1.x == position2.x;

  bool _horizontal(position1, position2) => position1.y == position2.y;

  bool _diagonal(position1, position2) {
    return ((position1.x - position2.y).abs() == 1 && 
        (position1.y - position2.x).abs()) &&
        !(position1.x == position2.x && position1.x == position2.x);
  }
 
  bool attemptWord(String word) {
    if (_wordIsValid(word)) {
      score += scoreForWord(word);
      words.add(word);
    }
  }
  
  int scoreForWord(String word) {
    return word.length;
  }
  
  Future get done {
    return whenDone.future;
  }
  
  bool _wordIsValid(String word) => dictionary.hasWord(word);
}
