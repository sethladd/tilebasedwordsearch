import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';
import 'package:game_loop/game_loop_html.dart';
import 'dart:math';

// The view of game in play
// Includes:
// - Tiles
// - Score
// - Timer
class GamePanel extends WebComponent {
  Game game;
  Dictionary dictionary;
  ImageAtlas letterAtlas;
  GameLoopHtml _gameLoop;
  GameLoopTouch currentTouch;
  bool paused = false;
  CanvasElement _canvasElement;
  ButtonElement _pauseButton;
  ButtonElement _endButton;

  @override
  inserted() {
    _pauseButton = query('#pause');
    _endButton = query('#end');
    _canvasElement = query('#frontBuffer');
    _gameLoop = new GameLoopHtml(_canvasElement);
    // Don't lock the pointer on a click.
    _gameLoop.pointerLock.lockOnClick = false;
    _gameLoop.onUpdate = gameUpdate;
    _gameLoop.onRender = gameRender;
    _gameLoop.onTouchStart = gameTouchStart;
    _gameLoop.onTouchEnd = gameTouchEnd;
    _gameLoop.keyboard.interceptor = keyboardEventInterceptor;
    enableButtons();

    startNewGame();
  }

  @override
  removed() {
    _gameLoop.keyboard.interceptor = null;
  }

  void startNewGame() {
    game = new Game(dictionary, _canvasElement, _gameLoop, letterAtlas);
    game.gameClock.start();
    game.done.then((_) {
      disableButtons();
    });
    _gameLoop.start();
  }

  void enableButtons() {
    _endButton.disabled = false;
    _pauseButton.disabled = false;
  }

  void disableButtons() {
    _endButton.disabled = true;
    _pauseButton.disabled = true;
  }

  void endGame() {
    // XXX: should confirm first
    game.stop();

    disableButtons();

    print('GAME ENDED');
  }

  void togglePause() {
    if (!paused) {
      game.gameClock.pause();
      _pauseButton.text = "Resume";
    } else {
      game.gameClock.restart();
      _pauseButton.text = "Pause";
    }
    paused = !paused;
  }

  void drawCircle(int x, int y) {
    var context = _canvasElement.context2d;
    context.beginPath();
    context.arc(x, y, 20.0, 0, 2 * PI);
    context.fillStyle = 'green';
    context.fill();
  }

  String _keyboardSearchString = '';

  String translateKeyboardButtonId(int buttonId) {
    if (buttonId >= Keyboard.A && buttonId <= Keyboard.Z) {
      return new String.fromCharCode(buttonId);
    }
    return '';
  }

  bool keyboardEventInterceptor(DigitalButtonEvent event, bool repeat) {
    if (repeat == true) {
      print('Repeat');
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
      print('Cleared');
      return true;
    }
    if (event.buttonId == Keyboard.ENTER) {
      // Submit.
      game.attemptWord(_keyboardSearchString);
      _keyboardSearchString = '';
      print('Cleared');
      return true;
    }
    String newSearchString = _keyboardSearchString +
                             translateKeyboardButtonId(event.buttonId);
    if (event.buttonId < Keyboard.A || event.buttonId > Keyboard.Z) {
      print('Invalid character.');
      return true;
    }
    print(newSearchString);
    print(event.buttonId);
    if (game.stringInGrid(newSearchString, null)) {
      print('String in grid.');
      _keyboardSearchString = newSearchString;
    } else if (event.buttonId == Keyboard.Q &&
               game.stringInGrid(newSearchString + 'U', null)) {
      print('Found for QU.');
      _keyboardSearchString = newSearchString;
    } else {
      print('Here');
      while (_keyboardSearchString.length > 0) {
        if (_keyboardSearchString[_keyboardSearchString.length-1] == 'Q') {
          _keyboardSearchString =
              _keyboardSearchString.substring(0,_keyboardSearchString.length-1);
        } else {
          break;
        }
      }
    }
    print(_keyboardSearchString);
    // Letter.
    return true;
  }


  void gameUpdateKeyboard() {
  }


  void gameUpdate(GameLoopHtml gameLoop) {
    if (TouchEvent.supported) {
      // Only support touch on touch enabled devices.
      game.board.update(currentTouch);
    } else {
      gameUpdateKeyboard();
    }
  }

  void gameRender(GameLoopHtml gameLoop) {
    game.selectSearchString(_keyboardSearchString);
    if (game != null) {
      game.board.render();
    }
    if (currentTouch == null) {
      return;
    }
    var transform = new RectangleTransform(_canvasElement);
    currentTouch.positions.forEach((position) {
      int x = position.x;
      int y = position.y;
      if (transform.contains(x, y)) {
        int rx = transform.transformX(x);
        int ry = transform.transformY(y);
        drawCircle(rx, ry);
      }
    });
  }

  void gameTouchStart(GameLoop gameLoop, GameLoopTouch touch) {
    if (currentTouch == null) {
      currentTouch = touch;
    }
  }

  void gameTouchEnd(GameLoop gameLoop, GameLoopTouch touch) {
    if (touch == currentTouch) {
      currentTouch = null;
      String word = game.board.selectedLetters;
      if (game.attemptWord(word)) {
        print('Found word $word');
      }
    }
  }
}