import 'package:polymer/polymer.dart';
import 'package:wordherd/shared_html.dart';
import 'package:wordherd/persistable_html.dart';
import 'package:logging/logging.dart';

final Logger log = new Logger('WordherdSoloGame');

@CustomTag('wordherd-sologame')
class WordherdSoloGame extends PolymerElement {
  @observable Game game;
  @observable Board board;
  @published String gameId;

  WordherdSoloGame.created() : super.created() {
    onPropertyChange(this, #gameId, _loadGame);
  }

  void _loadGame() {
    Persistable.load(gameId, GameSolo).then((GameSolo soloGame) {
      game = soloGame.game;
      board = soloGame.board;
    })
    .catchError((e, stackTrace) {
      log.severe('Error loading game $gameId: $e', e, stackTrace);
    });
  }
}