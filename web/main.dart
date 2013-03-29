import 'dart:html';
import 'dart:math';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import 'package:lawndart/lawndart.dart';
import 'package:route/client.dart';

import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';

CanvasElement _canvasElement;
GameLoop _gameLoop;
AssetManager assetManager = new AssetManager();
Dictionary dictionary;
ImageAtlas letterAtlas;
final Store highScoresStore = new IndexedDbStore('tbwg', 'highScores');
@observable Game game;

final Router router = new Router();
final UrlPattern gameUrl = new UrlPattern(r'/game');
final UrlPattern highScoresUrl = new UrlPattern(r'/high-scores');

@observable bool ready = false;
@observable bool showHighScores = false;

void drawCircle(int x, int y) {
  var context = _canvasElement.getContext('2d');
  context.beginPath();
  context.arc(x, y, 20.0, 0, 2 * PI);
  context.fillStyle = 'green';
  context.fill();
}

void initialize() {
  dictionary = new Dictionary.fromFile(assetManager['game.dictionary']);
  var letterTileImage = assetManager['game.tile-letters'];
  letterAtlas = new ImageAtlas(letterTileImage);
  final int offset = 11;
  final int letterWidth = 40;
  letterAtlas.addElement('a', offset, offset, letterWidth, letterWidth);
}

void startNewGame() {
  game = new Game(dictionary, _canvasElement, letterAtlas);
  game.done.then((_) {
    highScoresStore.save(game.score, new DateTime.now().toString());
  });
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

void displayHighScores() {
  highScoresStore.all().toList().then(() {

  });
}

main() {
  router.addHandler(highScoresUrl, (_) => showHighScores = true);
  assetManager.loaders['image'] = new ImageLoader();
  assetManager.importers['image'] = new NoopImporter();
  print('Touch events supported? ${TouchEvent.supported}');
  _canvasElement = query('#frontBuffer');
  _gameLoop = new GameLoop(_canvasElement);
  // Don't lock the pointer on a click.
  _gameLoop.pointerLock.lockOnClick = false;
  _gameLoop.onUpdate = gameUpdate;
  _gameLoop.onRender = gameRender;
  _gameLoop.onTouchStart = gameTouchStart;
  _gameLoop.onTouchEnd = gameTouchEnd;
  assetManager.loadPack('game', '../assets.pack')
      .then((_) => initialize())
      .then((_) => _gameLoop.start())
      .then((_) => startNewGame());
}
