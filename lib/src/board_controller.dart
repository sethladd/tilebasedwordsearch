part of tilebasedwordsearch;

class BoardController {
  final Board board;
  final BoardView view;

  BoardController(this.board, this.view);

  String selectedLetters = '';
  String _keyboardSearchString = '';
  String get keyboardSearchString => _keyboardSearchString;

  void clearSelected() {
    view.selectedTiles.clear();
    selectedLetters = '';
  }

  void selectSearchString(String searchString) {
    Set<List<int>> paths = new Set<List<int>>();
    if (searchString.length == 0) {
      return;
    }
    clearSelected();
    if (board.config.stringInGrid(searchString, paths)) {
      paths.forEach((path) {
        for (int i = 0; i < path.length; i++) {
          view.selectedTiles.add(path[i]);
        }
      });
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
      _keyboardSearchString = '';
      return true;
    }
    if (event.buttonId == Keyboard.ENTER) {
      // Submit.
      board.attemptWord(_keyboardSearchString);
      _keyboardSearchString = '';
      return true;
    }
    String newSearchString = _keyboardSearchString +
                             translateKeyboardButtonId(event.buttonId);
    if (event.buttonId < Keyboard.A || event.buttonId > Keyboard.Z) {
      return true;
    }
    if (board.config.stringInGrid(newSearchString, null)) {
      _keyboardSearchString = newSearchString;
    } else if (event.buttonId == Keyboard.Q &&
               board.config.stringInGrid(newSearchString + 'U', null)) {
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

  void update(GameLoopTouch touch) {
    double scaleX = view.scaleX;
    double scaleY = view.scaleY;
    if (touch != null) {
      for (var position in touch.positions) {
        int x = (position.x * scaleX).toInt();
        int y = (position.y * scaleY).toInt();
        for (int i = 0; i < GameConstants.BoardDimension; i++) {
          for (int j = 0; j < GameConstants.BoardDimension; j++) {
            int index = GameConstants.rowColumnToIndex(i, j);
            if (view.selectedTiles.contains(index)) {
              continue;
            }
            var transform = view.getTileRectangle(i, j);
            if (transform.contains(x, y)) {
              print('Adding $index');
              view.selectedTiles.add(index);
              selectedLetters += board.config.getChar(i,j);
            }
          }
        }
      }
    } else {
      clearSelected();
    }
  }
}