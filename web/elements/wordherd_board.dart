library wordherd_board;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:game_loop/game_loop_html.dart';
import 'dart:math';
import 'dart:async';
import 'package:wordherd/wordherd.dart';

@CustomTag('wordherd-board')
class WordherdBoard extends PolymerElement {
  Board board;
  BoardView boardView;
  BoardController boardController;
  GameClock _gameClock;
  GameLoopHtml _gameLoop;
  GameLoopTouch currentTouch;
  bool paused = false;
  CanvasElement _canvasElement;
  BodyElement _bodyElement;
  final Logger _gamePanelLogger = new Logger("GamePanel");

  StreamSubscription _onTouchStartSubscription;
  StreamSubscription _onTouchEndSubscription;

  _preventBubble(Event e) => e.preventDefault();
  
  @observable String wordInProgress = '';
  @observable String wordInProgressScore = '';
  @observable String pauseOrToggleText = 'Pause';

  @override
  inserted() {
    _canvasElement = $['frontBuffer'];
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
    _gameClock.start();
    _gameClock.allDone.future.then((_) {
    });
    _gameLoop.start();
  }

  void endGame(Event e, var detail, Node target) {
    if (window.confirm('Are you sure you want to end the game?')) {
      _gameClock.stop();
    }
  }

  void togglePause(Event e, var detail, Node target) {
    if (!paused) {
      _gameClock.pause();
      pauseOrToggleText = "Resume";
    } else {
      _gameClock.restart();
      pauseOrToggleText = "Pause";
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
    notifyProperty(this, #timeRemaining);
  }

  void gameRender(GameLoopHtml gameLoop) {
    if (paused) {
      boardView.renderPauseScreen();
      wordInProgress = 'Paused!';
      wordInProgressScore = '';
      return;
    }
    wordInProgress = boardController.wordInProgress;
    wordInProgressScore = boardController.wordInProgressScore.toString();
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
    _gamePanelLogger.fine('Open touches $touchCount');
  }

  void gameTouchEnd(GameLoop gameLoop, GameLoopTouch touch) {
    if (touch == currentTouch) {
      currentTouch = null;
      List<int> path = boardController.selectedPath;
      board.attemptPath(path);
    } else {
    }
    touchCount--;
    _gamePanelLogger.fine('Open touches $touchCount');
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