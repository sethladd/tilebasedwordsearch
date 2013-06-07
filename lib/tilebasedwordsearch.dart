library tilebasedwordsearch;

import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'package:game_loop/game_loop_html.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import "package:google_plus_v1_api/plus_v1_api_browser.dart";
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:google_games_v1_api/games_v1_api_browser.dart";

part 'src/board_view.dart';
part 'src/board.dart';
part 'src/game_clock.dart';
part 'src/dictionary.dart';
part 'src/rectangle_transform.dart';
part 'src/image_atlas.dart';
part 'src/game_score.dart';
part 'src/tile_set.dart';
part 'src/player.dart';
part 'src/score_board.dart';
part 'src/achievement.dart';

AssetManager assetManager = new AssetManager();
Dictionary dictionary;
ImageAtlas letterAtlas;
Player player;

@observable String currentPanel = 'login';

void parseAssets() {
  if (assetManager['game.dictionary'] == null) {
    throw new StateError("Can't play without a dictionary.");
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

Future initialize() {
  player = new Player();

  // Add players scoreboard/leaderboard from game play services
  player.scoreBoards.add(new ScoreBoard("CgkIoubq9KYHEAIQAQ", ScoreType.HIGH_SCORE));
  player.scoreBoards.add(new ScoreBoard("CgkIoubq9KYHEAIQAg", ScoreType.MOST_NUMBER_OF_WORDS));

  // Adding achievement that can be achieved
  player.achievement.add(new Achievement("CgkIoubq9KYHEAIQBA", AchievementType.SEVEN_LETTER_WORD));
  player.achievement.add(new Achievement("CgkIoubq9KYHEAIQBQ", AchievementType.EIGHT_LETTER_WORD));
  player.achievement.add(new Achievement("CgkIoubq9KYHEAIQBg", AchievementType.NINE_LETTER_WORD));
  player.achievement.add(new Achievement("CgkIoubq9KYHEAIQBw", AchievementType.TEN_LETTER_WORD));

  assetManager.loaders['image'] = new ImageLoader();
  assetManager.importers['image'] = new NoopImporter();

  print('Touch events supported? ${TouchEvent.supported}');

  return assetManager.loadPack('game', 'assets/_.pack')
      .then((_) => parseAssets());
}