import 'dart:html';
import 'dart:math';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:tilebasedwordsearch/dictionary.dart';
import 'package:tilebasedwordsearch/game.dart';

CanvasElement _canvasElement;
GameLoop _gameLoop;
AssetManager assetManager = new AssetManager();
Dictionary dictionary;
Game game;
BoardView _boardView;

void initialize() {
  dictionary = new Dictionary.fromFile(assetManager['game.dictionary']);
}

void startNewGame() {
  game = new Game(dictionary);
}

bool f = true;
void gameUpdate(GameLoop gameLoop) {
  // Game logic goes here.
  if (f) {
    print(assetManager['game.dictionary']);
    f = false;
  }
}

class TileCoord {
  num x, y;
  TileCoord(this.x, this.y);
}

class BoardView {
  int WIDTH = 320;
  int HEIGHT = 320;

  num tileSize;
  num gapSize;

  CanvasElement canvas;

  // TODO: Set these.
  String defaultColor;
  String selectedColor;

  BoardView(CanvasElement this.canvas) {
    init();
  }

  void init() {
    canvas.width = WIDTH;
    canvas.height = HEIGHT;

    var constraint = min(WIDTH, HEIGHT);
    tileSize = constraint / 4.75;
    gapSize = tileSize * 0.25;

  }

  TileCoord getTileCoord(int row, int column) {
    num x = column * (tileSize + gapSize);
    num y = row * (tileSize + gapSize);
    return new TileCoord(x, y);
  }

  void drawTile(String letter, int score) {
    // TODO.
  }

  void render() {
    var c = canvas.context2d;

    // Clear canvas.
    c.clearRect(0, 0, WIDTH, HEIGHT);

    // Loop through the tiles and draw each one.
    for (int i = 0; i < 4; i++) { // each row
      for (int j = 0; j < 4; j++) { // each column
        c.fillStyle = '#f00';

        var coord = getTileCoord(i, j);
        c.fillRect(coord.x, coord.y, tileSize, tileSize);

        c.fillStyle = '#000';
        c.font = '${(tileSize).floor()}px/${(tileSize).floor()} sans-serif';
        c.textBaseline = 'middle';

        var text = '$i';
        var width = c.measureText(text).width.clamp(0, tileSize);

        var textOffset = (tileSize - width) / 2;

        c.fillText(text, coord.x + textOffset, coord.y + tileSize * 0.5);
      }
    }


  }
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
