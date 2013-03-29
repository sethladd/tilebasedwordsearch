import 'dart:html';
import 'dart:math';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import 'package:lawndart/lawndart.dart';

import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';

CanvasElement _canvasElement;
GameLoop _gameLoop;
AssetManager assetManager = new AssetManager();
Dictionary dictionary;
BoardView _boardView;
final Store highScores = new IndexedDbStore('tbwg', 'highScores');
@observable Game game;

@observable bool ready = false;

void initialize() {
  dictionary = new Dictionary.fromFile(assetManager['game.dictionary']);
}

void startNewGame() {
  game = new Game(dictionary);
  game.done.then((_) {
    highScores.save(game.score, new DateTime().toString());
  });
}

void gameUpdate(GameLoop gameLoop) {
  // game.tick(gameLoop.dt);
}

void gameRender(GameLoop gameLoop) {
  _boardView.render();
}

void gameTouchStart(GameLoop gameLoop, GameLoopTouch touch) {
  print('Start ${touch.id}');
}

void gameTouchEnd(GameLoop gameLoop, GameLoopTouch touch) {
  print('End ${touch.id}');
  touch.positions.forEach((position) {
    print('${position.x}, ${position.y}');
  });
}

main() {
  print('Touch events supported? ${TouchEvent.supported}');
  _canvasElement = query('#frontBuffer');
  _boardView = new BoardView(_canvasElement);
  _gameLoop = new GameLoop(_canvasElement);
  // Don't lock the pointer on a click.
  _gameLoop.pointerLock.lockOnClick = false;
  _gameLoop.onUpdate = gameUpdate;
  _gameLoop.onRender = gameRender;
  _gameLoop.onTouchStart = gameTouchStart;
  _gameLoop.onTouchEnd = gameTouchEnd;
  assetManager.loadPack('game', '../assets.pack')
      .then((_) => initialize())
      .then((_) => _gameLoop.start());
}
