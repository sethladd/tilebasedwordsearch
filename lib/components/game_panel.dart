import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'package:meta/meta.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:tilebasedwordsearch/shared_html.dart';
import 'dart:math';
import 'dart:async';

class GamePanel extends WebComponent {
  BoardView boardView;
  BoardController boardController;
  GameClock _gameClock;
  ImageAtlas letterAtlas;
  GameLoopHtml _gameLoop;
  GameLoopTouch currentTouch;
  bool paused = false;
  CanvasElement _canvasElement;
  ButtonElement _pauseButton;
  ButtonElement _endButton;
  Game game;
  DivElement _selectedWord;
  BodyElement _bodyElement;

  @override
  inserted() {
    _pauseButton = query('#pause');
    _endButton = query('#end');
    _canvasElement = query('#frontBuffer');
    _selectedWord = query('selected-word');
    _bodyElement = query('body');
    _gameLoop = new GameLoopHtml(_canvasElement);
    _gameClock = new GameClock(_gameLoop);
    // Don't lock the pointer on a click.
    _gameLoop.pointerLock.lockOnClick = false;
    _bodyElement.classes.add('no-scroll');

    _gameLoop.onUpdate = gameUpdate;
    _gameLoop.onRender = gameRender;
    _gameLoop.onTouchStart = gameTouchStart;
    _gameLoop.onTouchEnd = gameTouchEnd;

    enableButtons();

    startOrResumeGame();
  }

  @override
  removed() {
    _gameLoop.keyboard.interceptor = null;
    _bodyElement.classes.remove('no-scroll');
    _gameLoop.stop();
  }

  void startOrResumeGame() {
    boardView = new BoardView(board, _canvasElement);
    boardController = new BoardController(board, boardView);
    _gameLoop.keyboard.interceptor = boardController.keyboardEventInterceptor;
    if (!game.started) {
      _gameClock.secondsRemaining = game.timeRemaining;
    }
    _gameClock.start();
    _gameClock.allDone.future.then((_) {
      _saveGame();
      currentPanel = 'results';
    });
    _saveGame();
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
      _saveGame();
      currentPanel = 'results';
    }
  }

  Future _saveGame() {
    game.board = board.tiles;
    game.timeRemaining = _gameClock.secondsRemaining;
    game.words = board.words.keys.toList();
    game.score = board.score;
    game.lastPlayed = new DateTime.now();
    return game.store().catchError(print);
  }

  void togglePause() {
    if (!paused) {
      _gameClock.pause();
      game.timeRemaining = _gameClock.secondsRemaining;
      _saveGame();
      _canvasElement.classes.add('hidden');
      _pauseButton.text = "Resume";
    } else {
      _gameClock.restart();
      _pauseButton.text = "Pause";
      _canvasElement.classes.remove('hidden');
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

  int touchCount = 0;
  void gameTouchStart(GameLoop gameLoop, GameLoopTouch touch) {
    if (currentTouch == null) {
      currentTouch = touch;
    } else {
    }
    touchCount++;
    print('Open touches $touchCount');
  }

  void gameTouchEnd(GameLoop gameLoop, GameLoopTouch touch) {
    if (touch == currentTouch) {
      currentTouch = null;
      List<int> path = boardController.selectedPath;
      board.attemptPath(path);
    } else {
    }
    touchCount--;
    print('Open touches $touchCount');
  }
}
