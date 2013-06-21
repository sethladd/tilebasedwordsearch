import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:tilebasedwordsearch/shared_html.dart';
import 'dart:math';

class GamePanel extends WebComponent {
  BoardView boardView;
  BoardController boardController;

  Boards boards;
  GameClock _gameClock;
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
    _gameClock = new GameClock(_gameLoop);
    // Don't lock the pointer on a click.
    _gameLoop.pointerLock.lockOnClick = false;


    _gameLoop.onUpdate = gameUpdate;
    _gameLoop.onRender = gameRender;
    _gameLoop.onTouchStart = gameTouchStart;
    _gameLoop.onTouchEnd = gameTouchEnd;

    enableButtons();

    startNewGame();
  }

  @override
  removed() {
    _gameLoop.keyboard.interceptor = null;
  }

  void startNewGame() {
    board = new Board(boards.getRandomBoard());
    boardView = new BoardView(board, _canvasElement);
    boardController = new BoardController(board, boardView);
    _gameLoop.keyboard.interceptor = boardController.keyboardEventInterceptor;
    _gameClock.start();
    _gameClock.allDone.future.then((_) {
      currentPanel = 'results';
    });
    words.clear();
    score = 0;
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
    if (window.confirm('Are you sure you want to end the game?')) {
      _gameClock.stop();
      currentPanel = 'results';
    }
  }

  void togglePause() {
    if (!paused) {
      _gameClock.pause();
      _pauseButton.text = "Resume";
    } else {
      _gameClock.restart();
      _pauseButton.text = "Pause";
    }
    paused = !paused;
  }

  void drawCircle(int x, int y) {
    var context = _canvasElement.context2D;
    context.beginPath();
    context.arc(x, y, 5.0, 0, 2 * PI);
    context.fillStyle = 'green';
    context.fill();
  }

  void gameUpdate(GameLoopHtml gameLoop) {
    boardController.update(currentTouch);
  }

  void gameRender(GameLoopHtml gameLoop) {
    if (boardView != null) {
      boardView.render();
    }
    if (currentTouch == null) {
      return;
    }
    var transform = new RectangleTransform(_canvasElement);
    currentTouch.positions.forEach((position) {
      int x = boardView.transformTouchToCanvasX(position.x);
      int y = boardView.transformTouchToCanvasY(position.y);
      drawCircle(x, y);
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
      List<int> path = boardController.selectedPath;
      board.attemptPath(path);
    }
  }
}
