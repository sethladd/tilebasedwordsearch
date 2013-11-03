import 'package:polymer/polymer.dart';
import 'package:wordherd/shared_html.dart' show Board, Game, GameSolo;
import 'package:wordherd/persistable_html.dart' show Persistable;
import 'package:logging/logging.dart' show Logger;

final Logger log = new Logger('WordherdSoloGame');

@CustomTag('wordherd-sologame')
class WordherdSoloGame extends PolymerElement {
  @observable GameSolo soloGame;
  @observable Game game;
  @observable Board board;
  @published String gameId;

  WordherdSoloGame.created() : super.created() {
    if (gameId != null) {
      _loadGame();
    } else {
      onPropertyChange(this, #gameId, _loadGame);
    }

    // Game can be null at created(), so use a path
    new PathObserver(this, 'game.isDone').changes.listen((_) {
      log.fine('Notified that game.isDone has changed');
      if (game.isDone) {
        _syncGameToServer();
      }
    });
  }

  _syncGameToServer() {
    soloGame.store()
    .then((_) => log.fine('Stored solo game into store'))
    .catchError((e, stackTrace) {
      log.severe('Could not sync solo game to store: $e', e, stackTrace);
    });
  }

  void _loadGame() {
    Persistable.load(gameId, GameSolo).then((GameSolo _soloGame) {
      soloGame = _soloGame;
      game = soloGame.game;
      board = soloGame.board;
    })
    .catchError((e, stackTrace) {
      log.severe('Error loading game $gameId: $e', e, stackTrace);
    });
  }
}