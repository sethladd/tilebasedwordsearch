import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:wordherd/shared_html.dart' show Boards, Game, GameSolo;
import 'package:wordherd/persistable_html.dart';
import 'dart:html' show Event, Node, document, window;
import 'wordherd_assets.dart' show WordherdAssets;

final Logger log = new Logger('WordherdSoloGames');

@CustomTag('wordherd-sologames')
class WordherdSoloGames extends PolymerElement {
  final List<GameSolo> soloGames = toObservable([]);
  WordherdAssets _assets;
  Boards _boards;

  WordherdSoloGames.created() : super.created();

  @override
  void enteredView() {
    super.enteredView();

    _assets = document.body.querySelector('wordherd-assets') as WordherdAssets;
    if (_assets == null) {
      log.severe('No wordherd-assets found in document body');
    }

    _boards = _assets.boards;

    log.fine('Loading all solo games');

    Persistable.all(GameSolo).toList()
    .then((List<GameSolo> allGames) {
      soloGames.addAll(allGames);
    })
    .catchError((e, stackTrace) {
      log.severe('Could not load games from local store: $e', e, stackTrace);
    });
  }

  void newSoloGame(Event e, var detail, Node target) {
    log.fine('Creating new solo game');
    GameSolo soloGame = new GameSolo()
      ..game = new Game()
      ..board = _boards.generateBoard();

    soloGame.store().then((String id) {
      window.location.hash = "/sologame/${soloGame.id}";
    })
    .catchError((e, stackTrace) {
      log.severe('Could not store new solo game: $e', e, stackTrace);
    });
  }

}