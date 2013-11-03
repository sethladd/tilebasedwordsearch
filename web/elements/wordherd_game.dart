library wordherd_game;

import 'package:polymer/polymer.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:logging/logging.dart';
import 'package:wordherd/image_atlas.dart';
import 'package:wordherd/shared_html.dart';
import 'dart:html';
import 'wordherd_assets.dart';

final Logger log = new Logger("WordherdGameElement");

@CustomTag('wordherd-game')
class WordherdGameElement extends PolymerElement {
  // TODO figure out how to eliminate this from this class
  AssetManager assetManager;

  ImageAtlas letterAtlas;
  ImageAtlas selectedLetterAtlas;
  ImageAtlas doubleLetterAtlas;
  ImageAtlas tripleLetterAtlas;
  ImageAtlas doubleWordAtlas;
  ImageAtlas tripleWordAtlas;

  @published Game game;
  @published Board board;

  @observable bool boardReady = false;

  WordherdGameElement.created() : super.created();

  void ready() {
    super.ready();

    // game might be null because it is set via binding,
    // so wait for game and then wait for isDone
    new PathObserver(this, 'game.isDone').changes.listen((_) {
      if (game.isDone) {
        dispatchEvent(new CustomEvent('gameover'));
      }
    });
  }

  @override
  void enteredView() {
    super.enteredView();

    // TODO handle an asset manager that isn't done loading assets
    WordherdAssets assets = document.body.querySelector('wordherd-assets') as WordherdAssets;

    // TODO gah I wish there was a toolable way to say this tag
    // expects another tag somewhere else

    if (assets == null) {
      log.severe('No wordherd-assets found in document body. Not good!');
    }

    assetManager = assets.assetManager;

    if (!assets.loaded) {
      log.severe('Assets not loaded. You are going to have a bad time');
    }

    _parseAssets();
  }

  void _parseAssets() {
    ImageElement letterTileImage = assetManager['game.tiles'];
    ImageElement selectedLetterTileImage = assetManager['game.tiles_highlighted'];
    ImageElement doubleLetterTileImage = assetManager['game.tiles_dl'];
    ImageElement doubleWordTileImage = assetManager['game.tiles_dw'];
    ImageElement tripleLetterTileImage = assetManager['game.tiles_tl'];
    ImageElement tripleWordTileImage = assetManager['game.tiles_tw'];
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

    boardReady = true;

    log.info('Assets loaded and parsed');
  }
}