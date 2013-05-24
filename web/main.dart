import 'dart:html';
import 'dart:async';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart';

AssetManager assetManager = new AssetManager();
Dictionary dictionary;
ImageAtlas letterAtlas;

@observable String currentPanel = 'main';

void initialize() {
  if (assetManager['game.dictionary'] == null) {
    throw new StateError('Can\'t play without a dictionary.');
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
}

main() {
  assetManager.loaders['image'] = new ImageLoader();
  assetManager.importers['image'] = new NoopImporter();

  print('Touch events supported? ${TouchEvent.supported}');

  assetManager.loadPack('game', '../assets/_.pack')
      .then((_) => initialize());
}
