library wordherd_game;

import 'package:polymer/polymer.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:logging/logging.dart';
import 'package:wordherd/image_atlas.dart';
import 'package:wordherd/wordherd.dart';

@CustomTag('wordherd-game')
class WordherdGameElement extends PolymerElement {
  final Logger clientLogger = new Logger("client");
  AssetManager assetManager = new AssetManager();
  
  ImageAtlas letterAtlas;
  ImageAtlas selectedLetterAtlas;
  ImageAtlas doubleLetterAtlas;
  ImageAtlas tripleLetterAtlas;
  ImageAtlas doubleWordAtlas;
  ImageAtlas tripleWordAtlas;
  
  Boards boards;
  
  created() {
    super.created();
    
    return assetManager.loadPack('game', 'assets/_.pack')
        .then((_) => _parseAssets());
  }
  
  void _parseAssets() {
    clientLogger.info('start processing assets');

    if (assetManager['game.boards'] == null) {
      throw new StateError("Can't play without the boards");
    }

    boards = new Boards(assetManager['game.boards']);

    var letterTileImage = assetManager['game.tiles'];
    var selectedLetterTileImage = assetManager['game.tiles_highlighted'];
    var doubleLetterTileImage = assetManager['game.tiles_dl'];
    var doubleWordTileImage = assetManager['game.tiles_dw'];
    var tripleLetterTileImage = assetManager['game.tiles_tl'];
    var tripleWordTileImage = assetManager['game.tiles_tw'];
    if (letterTileImage == null ||
        selectedLetterTileImage == null ||
        doubleLetterTileImage == null ||
        doubleWordTileImage == null ||
        tripleLetterTileImage == null ||
        tripleWordTileImage == null) {
      throw new StateError("Can't play without tile images.");
    }

    int offsetX = 16;
    int offsetY = 30;
    int sizeX = 94;
    int sizeY = 94;
    int gapX = 5;
    int gapY = 4;

    letterAtlas = new ImageAtlas(letterTileImage);
    selectedLetterAtlas = new ImageAtlas(selectedLetterTileImage);
    doubleLetterAtlas = new ImageAtlas(doubleLetterTileImage);
    tripleLetterAtlas = new ImageAtlas(tripleLetterTileImage);
    doubleWordAtlas = new ImageAtlas(doubleWordTileImage);
    tripleWordAtlas = new ImageAtlas(tripleWordTileImage);

    final int letterRow = 5;
    final int lettersPerRow = 6;
    const List<String> letters = const [ 'A', 'B', 'C', 'D', 'E', 'F',
                             'G', 'H', 'I', 'J', 'K', 'L',
                             'M', 'N', 'O', 'P', 'QU', 'R',
                             'S', 'T', 'U', 'V', 'W', 'X',
                             'Y', 'Z'];
    for (int i = 0; i < letterRow; i++) {
      for (int j = 0; j < lettersPerRow; j++) {
        int index = lettersPerRow * i + j;
        if (index >= letters.length) {
          break;
        }
        int x = offsetX + j * (sizeX + gapX);
        int y = offsetY + i * (sizeY + gapY);
        letterAtlas.addElement(letters[index], x, y, sizeX, sizeY);
        selectedLetterAtlas.addElement(letters[index], x, y, sizeX, sizeY);
        doubleLetterAtlas.addElement(letters[index], x, y, sizeX, sizeY);
        tripleLetterAtlas.addElement(letters[index], x, y, sizeX, sizeY);
        doubleWordAtlas.addElement(letters[index], x, y, sizeX, sizeY);
        tripleWordAtlas.addElement(letters[index], x, y, sizeX, sizeY);
      }
    }

    clientLogger.info('Assets loaded and parsed');
  }
}