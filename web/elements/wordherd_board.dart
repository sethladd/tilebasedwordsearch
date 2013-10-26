library wordherd_board;

import 'package:polymer/polymer.dart';
import 'dart:html' show BodyElement, CanvasElement, Event, Node, querySelector, window;
import 'package:logging/logging.dart' show Logger;
import 'package:meta/meta.dart' show override;
import 'package:game_loop/game_loop_html.dart' show GameLoop, GameLoopHtml, GameLoopTouch;
import 'dart:math' show PI;
import 'dart:async' show StreamSubscription;
import 'package:wordherd/client_game.dart' show BoardController, BoardView, GameClock, RectangleTransform, WordEvent;
import 'package:wordherd/shared_html.dart' show Board, Boards, Game;
import 'package:wordherd/image_atlas.dart' show ImageAtlas;

final Logger log = new Logger('WordherdBoard');

@CustomTag('wordherd-board')
class WordherdBoard extends PolymerElement {
  @published Board board;
  @published Game game;
  @observable String timeRemaining;
  
  // TODO replace with camelcase when bug is resolved
  
  @published ImageAtlas letteratlas;
  @published ImageAtlas selectedletteratlas;
  @published ImageAtlas doubleletteratlas;
  @published ImageAtlas tripleletteratlas;
  @published ImageAtlas doublewordatlas;
  @published ImageAtlas triplewordatlas;
  
  BoardView boardView;
  BoardController boardController;
  GameClock _gameClock;
  GameLoopHtml _gameLoop;
  GameLoopTouch currentTouch;
  bool paused = false;
  CanvasElement _canvasElement;
  BodyElement _bodyElement;
  final Logger _gamePanelLogger = new Logger("WordherdBoard");

  StreamSubscription _onTouchStartSubscription;
  StreamSubscription _onTouchEndSubscription;

  _preventBubble(Event e) => e.preventDefault();
  
  @observable String wordInProgress = '';
  @observable String wordInProgressScore = '';
  @observable String pauseOrToggleText = 'Pause';
  
  WordherdBoard.created() : super.created();

  @override
  void enteredView() {
    super.enteredView();
    
    _canvasElement = $['frontBuffer'];
    _bodyElement = querySelector('body');
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

  // TODO this isn't being called, but hopefully it will be when leftView works
  // BUG: this doesn't fire, two levels deep.
  // See this thread: https://groups.google.com/a/dartlang.org/forum/#!topic/web-ui/Y1-F2ErXICY
  @override
  void leftView() {
    super.leftView();
    
    _gameLoop.keyboard.interceptor = null;
    // TODO move this to data binding
    _bodyElement.classes.remove('no-scroll');
    _onTouchStartSubscription.cancel();
    _onTouchEndSubscription.cancel();
    _gameLoop.stop();
    
    log.fine('board was removed');
  }

  void startOrResumeGame() {
    _gamePanelLogger.severe("starting game");
    boardView = new BoardView(board, _canvasElement, triplewordatlas,
        letteratlas, selectedletteratlas, tripleletteratlas);
    boardController = new BoardController(board, boardView);
    boardController.onWords.listen((WordEvent e) => game.scoreWord(e.word, e.score));
    _gameLoop.keyboard.interceptor = boardController.keyboardEventInterceptor;
    _gameClock.start();
    _gameClock.whenDone.then((_) {
      game.isDone = true;
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
    timeRemaining = _timeRemaining;
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
      bool goodWord = board.attemptPathAsWord(path);
      if (goodWord) {
        game.scoreWord(board.wordForPath(path), board.scoreForPath(path));
      }
    } else {
    }
    touchCount--;
    _gamePanelLogger.fine('Open touches $touchCount');
  }

  // This is "observable" based on the gameUpdate above.
  // Perhaps one day we'll be able to use an annotation here to make it
  // more obvious.
  String get _timeRemaining {
    if (_gameClock == null) return '-';
    
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