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
  }
  
  void startNewGame() {
    game = new Game(dictionary, _canvasElement, _gameLoop, letterAtlas);
    game.gameClock.start();
    game.done.then((_) {
      disableButtons();
    });
    _gameLoop.start();
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

  void gameUpdate(GameLoopHtml gameLoop) {
    game.board.update(currentTouch);
  }

  void gameRender(GameLoopHtml gameLoop) {
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