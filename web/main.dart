import 'dart:html';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';

CanvasElement _canvasElement;
GameLoop _gameLoop;
AssetManager assetManager = new AssetManager();

bool f = true;
void gameUpdate(GameLoop gameLoop) {
  // Game logic goes here.
  if (f) {
    print(assetManager['game.dictionary']);
    f = false;
  }
}

void gameRender(GameLoop gameLoop) {
  // Paint here.
}

main() {
  _canvasElement = query('#frontBuffer');
  _gameLoop = new GameLoop(_canvasElement);
  _gameLoop.onUpdate = gameUpdate;
  _gameLoop.onRender = gameRender;
  assetManager.loadPack('game', 'assets.pack').then((_) => _gameLoop.start());
}
