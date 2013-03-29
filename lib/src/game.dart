part of tilebasedwordsearch;

@observable
class Game {
  
  static const DIMENSIONS = 4;
  static Map<String, num> LETTERS =  {'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1, 
                                  'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
                                   'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1, 'P': 3, 
                                   'QU': 10, 'R': 1, 'S': 1, 'T': 1, 'U': 1, 'V': 4,
                                   'W': 4, 'X': 8, 'Y': 4, 'Z': 10};
  
  var grid = new List.generate(4, (_) => new List<String>(4));
  
  int score = 0;
  Dictionary dictionary;
  List<String> words = <String>[];

  CanvasElement canvas;

  GameClock gameClock;
  BoardView board;
  
  Completer whenDone = new Completer();
  
  Game(this.dictionary, this.canvas, gameLoop) {
    _assignCharsToTiles();
    board = new BoardView(this, canvas);
    gameClock = new GameClock(gameLoop);
    gameClock.start();
  }
  
  void _assignCharsToTiles() {
    Random random = new Random();
    for (var i = 0; i < DIMENSIONS; i++) {
      for (var j = 0; j < DIMENSIONS; j++) {
        var keys = LETTERS.keys.toList();
        var char = keys[random.nextInt(LETTERS.length)];
        this.grid[i][j] = char;
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
