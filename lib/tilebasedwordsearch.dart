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
import "package:google_games_v1_api/games_v1_api_browser.dart" as gg;
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

resumeGame(Game resumedGame) {
  clientLogger.info('Resuming game ${resumedGame.id}');
  game = resumedGame;
  print(game.board);
  BoardConfig boardConfig = new BoardConfig.fromGame(boards, resumedGame);
  print(boardConfig.board);
  board = new Board.fromGame(boardConfig, resumedGame);
  currentPanel = 'game';
}

newGame({TwoPlayerMatch match}) {
  queryAll('.list-games-panel').forEach((item) => item.remove());
  BoardConfig boardConfig = new BoardConfig(boards);
  board = new Board(boardConfig);
  game = new Game(GameClock.DEFAULT_GAME_LENGTH,
      board.tiles,
      boardConfig.letterBonusTileIndexes,
      boardConfig.wordBonusTileIndex);

  if (match != null) {
    game.matchId = match.id;
  }

  game.store().then((_) {
    games.add(game);
    currentPanel = 'game';
  })
  .catchError((e) {
    clientLogger.warning('Could not store game into local db: $e');
  });

}

newMultiplayerGame() {
  currentPanel = 'newMultiplayerGame';
//  player.refreshHighScoreLeaderboard();
}

signedIn(SimpleOAuth2 authenticationContext, [Map authResult]) {
  player.signedIn(authenticationContext, authResult).then((_) {

    clientLogger.fine('Getting twoplayermatch from server');

    return HttpRequest.request('/multiplayer_games/me', method: 'GET')
    .then((HttpRequest req) {
      List<TwoPlayerMatch> matches = JSON.parse(req.responseText)
          .map((Map data) => new TwoPlayerMatch.fromPersistence(data['id'], data));

      // TODO find the ones that aren't in the DB and store them
    })
    .catchError((e) {
      clientLogger.warning('Could not fetch twoplayermatch from server: $e');
    });

  });
}

signedOut() {
  player.signedOut();
}

Future initialize() {
  player = new Player();

  assetManager.loaders['image'] = new ImageLoader();
  assetManager.importers['image'] = new NoopImporter();

  print('Touch events supported? ${TouchEvent.supported}');

  return assetManager.loadPack('game', 'assets/_.pack')
      .then((_) => parseAssets())
      .then((_) => db.init('wordherd', Game))
      .then((_) => db.init('wordherd', TwoPlayerMatch))
      .then((_) {
        return db.Persistable.all(Game, (String id, Map data) => new Game.fromPersistence(id, data))
            .toList().then((g) => games.addAll(g));
      });
}

String encodeMap(Map data) {
  return data.keys.map((k) {
    return '${Uri.encodeComponent(k)}=${Uri.encodeComponent(data[k])}';
  }).join('&');
}
