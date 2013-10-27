part of client_game;

class WordEvent {
  final String word;
  final int score;
  WordEvent(this.word, this.score);
}

class BoardController {
  final Board board;
  final BoardView view;
  
  List<int> selectedPath;
  String _keyboardSearchString = '';
  
  // TODO I think I can delete these
  String wordInProgress = '';
  int wordInProgressScore = 0;
  
  StreamController<WordEvent> _wordsStream = new StreamController();

  BoardController(this.board, this.view);

  Stream<WordEvent> get onWords => _wordsStream.stream;

  void clearSelected() {
    view.selectedTiles.clear();
    selectedPath = null;
    wordInProgress = '';
    wordInProgressScore = 0;
  }

  void clearKeyboardInput() {
    _keyboardSearchString = '';
    wordInProgress = '';
    wordInProgressScore = 0;
  }

  int _comparePaths(List<int> a, List<int> b) {
    int aLength = a.length;
    int bLength = b.length;
    if (aLength != bLength) {
      return aLength - bLength;
    }
    for (int i = 0; i < aLength; i++) {
      int diff = a[i] - b[i];
      if (diff != 0) {
        return diff;
      }
    }
    return 0;
  }

  List<List<int>> sortPathSet(Set<List<int>> paths) {
    List out = paths.toList();
    out.sort(_comparePaths);
    return out;
  }

  void updateFromKeyboard() {
    clearSelected();
    if (_keyboardSearchString.length == 0) {
      return;
    }
    Set<List<int>> paths = new Set<List<int>>();

    // Find the best path.
    List<int> bestPath;
    int bestScore = 0;
    if (board.stringInGrid(_keyboardSearchString, paths)) {
      List listOfPaths = sortPathSet(paths);
      listOfPaths.forEach((path) {
        int pathScore = board.scoreForPath(path);
        if (pathScore > bestScore) {
          bestPath = path;
          bestScore = pathScore;
        }
      });
    }
    if (bestPath != null) {
      selectedPath = bestPath;
      wordInProgress = board.wordForPath(selectedPath);
      wordInProgressScore = board.scoreForPath(selectedPath);
      for (int i = 0; i < selectedPath.length; i++) {
        view.selectedTiles.add(selectedPath[i]);
      }
    }
  }

  String translateKeyboardButtonId(int buttonId) {
    if (buttonId >= Keyboard.A && buttonId <= Keyboard.Z) {
      return new String.fromCharCode(buttonId);
    }
    return '';
  }

  bool keyboardEventInterceptor(DigitalButtonEvent event, bool repeat) {
    if (repeat == true) {
      return true;
    }
    if (event.down == false) {
      return true;
    }
    if (event.buttonId == Keyboard.ESCAPE ||
        event.buttonId == Keyboard.SPACE) {
      // Space or escape kills the current word search.
      // TODO: Indicate in GUI.
      clearKeyboardInput();
      return true;
    }
    if (event.buttonId == Keyboard.ENTER) {
      // Submit.
      board.attemptPathAsWord(selectedPath);
      bool goodWord = board.attemptPathAsWord(selectedPath);
      if (goodWord) {
        _wordsStream.add(new WordEvent(board.wordForPath(selectedPath), board.scoreForPath(selectedPath)));
      }
      clearKeyboardInput();
      return true;
    }
    String newSearchString = _keyboardSearchString +
                             translateKeyboardButtonId(event.buttonId);
    if (event.buttonId < Keyboard.A || event.buttonId > Keyboard.Z) {
      return true;
    }
    if (board.stringInGrid(newSearchString, null)) {
      _keyboardSearchString = newSearchString;
    } else if (event.buttonId == Keyboard.Q &&
               board.stringInGrid(newSearchString + 'U', null)) {
      _keyboardSearchString = newSearchString;
    } else {
      while (_keyboardSearchString.length > 0) {
        if (_keyboardSearchString[_keyboardSearchString.length-1] == 'Q') {
          _keyboardSearchString =
              _keyboardSearchString.substring(0,_keyboardSearchString.length-1);
        } else {
          break;
        }
      }
    }
    return true;
  }

  void testPoint(int x, int y) {
    for (int i = 0; i < GameConstants.BoardDimension; i++) {
      for (int j = 0; j < GameConstants.BoardDimension; j++) {
        int index = GameConstants.rowColumnToIndex(i, j);
        if (view.selectedTiles.contains(index)) {
          continue;
        }
        var transform = view.getTileRectangle(i, j);
        if (transform.containsTouch(x, y)) {
          view.selectedTiles.add(index);
          if (selectedPath == null) {
            selectedPath = new List<int>();
          }
          selectedPath.add(index);
        }
      }
    }
  }

  void _testLine(int i, int j, int x0, int y0, int x1, int y1) {
    int index = GameConstants.rowColumnToIndex(i, j);
    if (view.selectedTiles.contains(index)) {
      return;
    }
    var transform = view.getTileRectangle(i, j);
    if (transform.containsLine(x0, y0, x1, y1)) {
      view.selectedTiles.add(index);
      if (selectedPath == null) {
        selectedPath = new List<int>();
      }
      selectedPath.add(index);
    }
  }

  void testLine(int x0, int y0, int x1, int y1) {
    bool moveRight = x1 > x0;
    bool moveDown = y1 > y0;
    if (moveDown) {
      // Scan starting at the top of the board moving down.
      for (int i = 0; i < GameConstants.BoardDimension; i++) {
        if (moveRight) {
          // Scan starting at the left moving to the right.
          for (int j = 0; j < GameConstants.BoardDimension; j++) {
            _testLine(i, j, x0, y0, x1, y1);
          }
        } else {
          // Scan starting at the right moving to the left.
          for (int j = GameConstants.BoardDimension-1; j >= 0; j--) {
            _testLine(i, j, x0, y0, x1, y1);
          }
        }
      }
    } else {
      // Scan starting at the bottom of the board up.
      for (int i = GameConstants.BoardDimension-1; i >= 0; i--) {
        if (moveRight) {
          // Scan starting at the left moving to the right.
          for (int j = 0; j < GameConstants.BoardDimension; j++) {
            _testLine(i, j, x0, y0, x1, y1);
          }
        } else {
          // Scan starting at the right moving to the left.
          for (int j = GameConstants.BoardDimension-1; j >= 0; j--) {
            _testLine(i, j, x0, y0, x1, y1);
          }
        }
      }
    }
  }

  void updateFromTouch(GameLoopTouch touch) {
    double scaleX = view.scaleX;
    double scaleY = view.scaleY;
    if (touch != null) {
      // If we have a touch, ignore keyboard input.
      clearKeyboardInput();
      clearSelected();
      for (int i = 0; i < touch.positions.length-1; i++) {
        var position0 = touch.positions[i];
        var position1 = touch.positions[i+1];
        int x0 = view.transformTouchToCanvasX(position0.x);
        int y0 = view.transformTouchToCanvasY(position0.y);
        int x1 = view.transformTouchToCanvasX(position1.x);
        int y1 = view.transformTouchToCanvasY(position1.y);
        testPoint(x0, y0);
        testLine(x0, y0, x1, y1);
        testPoint(x1, y1);
      }
      wordInProgress = board.wordForPath(selectedPath);
      wordInProgressScore = board.scoreForPath(selectedPath);
    }
  }

  void update(GameLoopTouch touch) {
    clearSelected();
    updateFromKeyboard();
    updateFromTouch(touch);
  }
}