part of tilebasedwordsearch;

class BoardController {
  final Board board;
  final BoardView view;

  BoardController(this.board, this.view);

  String _keyboardSearchString = '';
  String get keyboardSearchString => _keyboardSearchString;

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

}