library tilebasedwordsearch;

import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'dart:json' as JSON;
import 'package:logging/logging.dart';
import 'package:tilebasedwordsearch/persistable_html.dart' as db;
import 'package:tilebasedwordsearch/shared_html.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import "package:google_plus_v1_api/plus_v1_api_browser.dart";
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:google_games_v1_api/games_v1_api_browser.dart";
import 'package:tilebasedwordsearch/game_constants.dart';

part 'src/board_view.dart';
part 'src/board.dart';
part 'src/board_controller.dart';
part 'src/game_clock.dart';
part 'src/rectangle_transform.dart';
part 'src/image_atlas.dart';
part 'src/game_score.dart';
part 'src/tile_set.dart';
part 'src/player.dart';
part 'src/score_board.dart';
part 'src/achievement.dart';

AssetManager assetManager = new AssetManager();
Boards boards;
ImageAtlas letterAtlas;
ImageAtlas selectedLetterAtlas;
ImageAtlas doubleLetterAtlas;
ImageAtlas tripleLetterAtlas;
ImageAtlas doubleWordAtlas;
ImageAtlas tripleWordAtlas;
Player player;
final Logger clientLogger = new Logger("client");
Random random = new Random();

// Different panels need access to the board.
Board board;

// Use this until we fix route and add it back in
Game game;

@observable String currentPanel = 'main';

final List games = toObservable([]);

void parseAssets() {
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
    throw new StateError("Can\'t play without tile images.");
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
  List<String> letters = [ 'A', 'B', 'C', 'D', 'E', 'F',
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

resumeGame(Game g) {
  clientLogger.info('Resuming game ${g.dbId}');
  game = g;
  BoardBonusConfig bonusConfig = new BoardBonusConfig.fromGame(game);
  board = new Board.fromGame(boards.getBoardFromString(game.board), bonusConfig,
                             g);
  currentPanel = 'game';
}

newGame() {
  var bonusConfig = new BoardBonusConfig();
  board = new Board(boards.getRandomBoard(), bonusConfig);
  game = new Game()
    ..timeRemaining = GameClock.DEFAULT_GAME_LENGTH
    ..board = board.tiles;
  game.letterBonusTiles = board.bonusConfig.letterBonusTileIndexes;
  game.wordBonusTile = board.bonusConfig.wordBonusTileIndex;
  games.add(game);
  currentPanel = 'game';
}

newMultiplayerGame() {
  currentPanel = 'highScores';
  player.refreshHighScoreLeaderboard();
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
      .then((_) => parseAssets())
      .then((_) => db.init('wordherd', 'wordherd'))
      .then((_) {
        return db.Persistable.all((String id, Map data) => new Game.fromPersistence(id, data))
            .toList().then((g) => games.addAll(g));
      });
}