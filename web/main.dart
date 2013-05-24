import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'package:game_loop/game_loop_html.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import 'package:lawndart/lawndart.dart';
import 'package:route/client.dart';

import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';

CanvasElement _canvasElement;
GameLoopHtml _gameLoop;
AssetManager assetManager = new AssetManager();
Dictionary dictionary;
ImageAtlas letterAtlas;
final Store highScoresStore = new IndexedDbStore('tbwg', 'highScores');
final List<int> highScores = toObservable([]);
@observable Game game;

final Router router = new Router();
final UrlPattern gameUrl = new UrlPattern(r'/game');
final UrlPattern highScoresUrl = new UrlPattern(r'/high-scores');

@observable bool ready = false;
@observable bool showHighScores = false;

bool paused = false;

void drawCircle(int x, int y) {
  var context = _canvasElement.context2d;
  context.beginPath();
  context.arc(x, y, 20.0, 0, 2 * PI);
  context.fillStyle = 'green';
  context.fill();
}

Future initialize() {
  if (assetManager['game.dictionary'] == null) {
    throw(new StateError('Can\'t play without a dictionary.'));
  }
  dictionary = new Dictionary.fromFile(assetManager['game.dictionary']);
  
  var letterTileImage = assetManager['game.tile-letters'];
  if (letterTileImage == null) {
    throw(new StateError('Can\'t play without tile images.'));
  }
  
  letterAtlas = new ImageAtlas(letterTileImage);
  final int letterRow = 5;
  final int lettersPerRow = 6;
  final int letterWidth = 70;
  List<String> letters = [ 'A', 'B', 'C', 'D', 'E', 'F',
                           'G', 'H', 'I', 'J', 'K', 'L',
                           'M', 'N', '~N', 'O', 'P', 'Q',
                           'QU', 'R', 'rr', 'S', 'T', 'U',
                           'V', 'W', 'X', 'Y', 'Z', ' '];
  for (int i = 0; i < letterRow; i++) {
    for (int j = 0; j < lettersPerRow; j++) {
      int index = (i * lettersPerRow) + j;
      int x = j * letterWidth;
      int y = i * letterWidth;
      letterAtlas.addElement(letters[index], x, y, letterWidth, letterWidth);
    }
  }
  return highScoresStore.open();

}

void startNewGame() {
  game = new Game(dictionary, _canvasElement, _gameLoop, letterAtlas);
  (query('#start-game-button') as ButtonElement).disabled = true;
  game.gameClock.start();
  game.done.then((_) {
    highScoresStore.save(game.score, new DateTime.now().toString());
    highScores.add(game.score);
    (query('#start-game-button') as ButtonElement).disabled = false;
  });
}

void togglePause() {
  var button = query('#pause-button');

  if (!paused) {
    game.gameClock.pause();
    button.text = "Resume";
  } else {
    game.gameClock.restart();
    button.text = "Pause";
  }
  paused = !paused;
}

void gameUpdate(GameLoop gameLoop) {
  //_boardView.update(currentTouch);
  // game.tick(gameLoop.dt);
}

void gameRender(GameLoop gameLoop) {
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

GameLoopTouch currentTouch;

void gameTouchStart(GameLoop gameLoop, GameLoopTouch touch) {
  if (currentTouch == null) {
    currentTouch = touch;
  }
}

void gameTouchEnd(GameLoop gameLoop, GameLoopTouch touch) {
  if (touch == currentTouch) {
    currentTouch = null;
  }
}

Future loadHighScores() {
  return highScoresStore.all().toList().then((scores) {
    highScores.addAll(scores);
  });
}

main() {
  /*
  router
    ..addHandler(highScoresUrl, (_) => showHighScores = true)
    ..listen();
  */

  assetManager.loaders['image'] = new ImageLoader();
  assetManager.importers['image'] = new NoopImporter();

  print('Touch events supported? ${TouchEvent.supported}');
  _canvasElement = query('#frontBuffer');
  _gameLoop = new GameLoopHtml(_canvasElement);
  // Don't lock the pointer on a click.
  _gameLoop.pointerLock.lockOnClick = false;
  _gameLoop.onUpdate = gameUpdate;
  _gameLoop.onRender = gameRender;
  _gameLoop.onTouchStart = gameTouchStart;
  _gameLoop.onTouchEnd = gameTouchEnd;
  assetManager.loadPack('game', '../assets/_.pack')
      .then((_) => initialize())
      .then((_) => loadHighScores())
      .then((_) => _gameLoop.start())
      .then((_) {
        (query('#start-game-button') as ButtonElement).disabled = false;
        (query('#pause-button') as ButtonElement).disabled = false;
      });
}
