import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'package:logging/logging.dart';
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
  Function submitHighScore;
  GameLoopHtml _gameLoop;
  GameLoopTouch currentTouch;
  bool paused = false;
  CanvasElement _canvasElement;
  ButtonElement _pauseButton;
  ButtonElement _endButton;
  Game game;
  DivElement _selectedWord;
  BodyElement _bodyElement;
  final Logger _gamePanelLogger = new Logger("GamePanel");

  StreamSubscription _onTouchStartSubscription;
  StreamSubscription _onTouchEndSubscription;

  _preventBubble(Event e) => e.preventDefault();

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

    // Prevent touch events to escape the canvas element so scrolling does not happen.
    _onTouchStartSubscription = _canvasElement.onTouchStart.listen(_preventBubble);
    _onTouchEndSubscription = _canvasElement.onTouchEnd.listen(_preventBubble);

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
    _onTouchStartSubscription.cancel();
    _onTouchEndSubscription.cancel();
    _gameLoop.stop();
  }

  void startOrResumeGame() {
    boardView = new BoardView(board, _canvasElement);
    boardController = new BoardController(board, boardView);
    _gameLoop.keyboard.interceptor = boardController.keyboardEventInterceptor;
    if (game.started) {
      _gameClock.secondsRemaining = game.timeRemaining;
    }
    _gameClock.start();
    _gameClock.allDone.future.then((_) {
      _saveGame();

      if (submitHighScore != null) {
        _gamePanelLogger.fine("submitScore(ScoreType.HIGH_SCORE, ${board.score})");
        submitHighScore(ScoreType.HIGH_SCORE, board.score);
      }

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

  /** Returns the user to the home screen. */
  void goHome() {
    if (!paused) togglePause();
    currentPanel = 'main';
  }

  void endGame() {
    if (window.confirm('Are you sure you want to end the game?')) {
      _gameClock.stop();
      _saveGame();
      currentPanel = 'results';
    }
  }

  Future _saveGame() {
    // TODO move all this into Board ?
    game.timeRemaining = _gameClock.secondsRemaining;
    game.words = board.words;
    game.recentWords = board.recentWords;
    game.score = board.score;
    game.lastPlayed = new DateTime.now();
    game.board = board.tiles;
    return game.store().catchError(print);
  }

  void togglePause() {
    if (!paused) {
      _gameClock.pause();
      game.timeRemaining = _gameClock.secondsRemaining;
      _saveGame();
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
    if (paused) {
      boardView.renderPauseScreen();
      return;
    }
    if (boardView != null) {
      boardView.render();
    }
    if (currentTouch == null) {
      return;
    }
    bool drawTouchPoints = false;
    if (drawTouchPoints) {
      var transform = new RectangleTransform(_canvasElement);
      currentTouch.positions.forEach((position) {
        int x = boardView.transformTouchToCanvasX(position.x);
        int y = boardView.transformTouchToCanvasY(position.y);
        drawCircle(x, y);
      });
    }
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

  String get timeRemaining {
    int seconds = _gameClock.secondsRemaining;

    if (seconds <= 0) return 'GAME OVER'; // XXX ok for stop() case?

    int m = seconds ~/ 60;
    int s = seconds % 60;

    String minuteString = "";
    String secondString = "";

    if (m > 0) {
      minuteString = '${m.toString()}:';
      secondString = (s <= 9) ? '0$s' : '$s';
    } else {
      secondString = s.toString();
    }
    return '$minuteString$secondString';
  }
}
