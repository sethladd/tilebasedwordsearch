// Auto-generated from game_panel.html.
// DO NOT EDIT.

library game_panel;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;
import 'package:web_ui/observe/observable.dart' as __observe;
import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'package:meta/meta.dart';
import '../tilebasedwordsearch.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:tilebasedwordsearch/shared_html.dart';
import 'dart:math';
import 'dart:async';



class GamePanel extends WebComponent {
  /** Autogenerated from the template. */

  autogenerated.ScopedCssMapper _css;

  /** This field is deprecated, use getShadowRoot instead. */
  get _root => getShadowRoot("game-panel");
  static final __html1 = new autogenerated.Element.html('<label class="selected-word">last word</label>'), __html2 = new autogenerated.Element.html('<label class="selected-word"></label>'), __html3 = new autogenerated.Element.html('<div class="score"></div>'), __html4 = new autogenerated.Element.html('<div class="time"></div>'), __shadowTemplate = new autogenerated.DocumentFragment.html('''
        <div class="selected-word">
          <template></template>
          <template></template>
        </div>
        <canvas id="frontBuffer" class="board"></canvas>
        <div class="game-data">
          <template></template>
        </div> <!-- end of game-data class -->
        <div>
          <button class="pause" id="pause" disabled="">Pause</button>
          <button id="end" disabled="">End game</button>
        </div>

      ''');
  autogenerated.ButtonElement __e38, __e39;
  autogenerated.Element __e29, __e32, __e37;
  autogenerated.Template __t;

  void created_autogenerated() {
    var __root = createShadowRoot("game-panel");
    setScopedCss("game-panel", new autogenerated.ScopedCssMapper({"game-panel":"[is=\"game-panel\"]"}));
    _css = getScopedCss("game-panel");
    __t = new autogenerated.Template(__root);
    __root.nodes.add(__shadowTemplate.clone(true));
    __e29 = __root.nodes[1].nodes[1];
    __t.conditional(__e29, () => board.recentWords.isEmpty, (__t) {
    __t.addAll([new autogenerated.Text('\n            '),
        __html1.clone(true),
        new autogenerated.Text('\n          ')]);
    });

    __e32 = __root.nodes[1].nodes[3];
    __t.conditional(__e32, () => !board.recentWords.isEmpty, (__t) {
      var __e31;
      __e31 = __html2.clone(true);
      var __binding30 = __t.contentBind(() => board.recentWords[0], false);
      __e31.nodes.add(__binding30);
    __t.addAll([new autogenerated.Text('\n            '),
        __e31,
        new autogenerated.Text('\n          ')]);
    });

    __e37 = __root.nodes[5].nodes[1];
    __t.conditional(__e37, () => board != null, (__t) {
      var __e34, __e36;
      __e34 = __html3.clone(true);
      var __binding33 = __t.contentBind(() => board.score, false);
      __e34.nodes.add(__binding33);
      __e36 = __html4.clone(true);
      var __binding35 = __t.contentBind(() => _gameClock.timeRemaining, false);
      __e36.nodes.add(__binding35);
    __t.addAll([new autogenerated.Text('\n            '),
        __e34,
        new autogenerated.Text('\n            '),
        __e36,
        new autogenerated.Text('\n          ')]);
    });

    __e38 = __root.nodes[9].nodes[1];
    __t.listen(__e38.onClick, ($event) { togglePause(); });
    __e39 = __root.nodes[9].nodes[3];
    __t.listen(__e39.onClick, ($event) { endGame(); });
    __t.create();
  }

  void inserted_autogenerated() {
    __t.insert();
  }

  void removed_autogenerated() {
    __t.remove();
    __t = __e29 = __e32 = __e37 = __e38 = __e39 = null;
  }

  /** Original code from the component. */

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

    startNewGame();
  }

  @override
  removed() {
    _gameLoop.keyboard.interceptor = null;
    _bodyElement.classes.remove('no-scroll');
    _gameLoop.stop();
  }

  void startNewGame() {
    board = new Board(boards.getRandomBoard());
    boardView = new BoardView(board, _canvasElement);
    boardController = new BoardController(board, boardView);
    _gameLoop.keyboard.interceptor = boardController.keyboardEventInterceptor;
    _gameClock.start();
    _gameClock.allDone.future.then((_) {
      _saveGame();
      currentPanel = 'results';
    });
    game = new Game();
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

//# sourceMappingURL=game_panel.dart.map