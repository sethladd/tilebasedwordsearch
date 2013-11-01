// DO NOT add show's here, the code generation messes that up
import 'package:polymer/polymer.dart';
import 'package:wordherd/shared_html.dart' show GameMatch, Game;

@CustomTag('wordherd-gamematch-row')
class WordherdGamematchRow extends PolymerElement {
  @published GameMatch gameMatch;
  @published String playerId;
  @observable bool isReady = false;
  
  WordherdGamematchRow.created() : super.created() {
    onPropertyChange(this, #gameMatch, () {
      isReady = _isReady;
    });
    
    onPropertyChange(this, #playerId, () {
      isReady = _isReady;
    });
  }
  
  String get matchResult {
    if (gameMatch == null) return '';
    
    if (!gameMatch.isOver) {
      return 'In Progress';
    } else if (gameMatch.winningId == playerId) {
      return 'Ya Won';
    } else if (gameMatch.winningId != playerId) {
      return 'Ya Lost';
    }
  }
  
  String get startOrResumeMsg {
    if (gameMatch == null) return '';
    
    Game game = gameMatch.myGame(playerId);
    return (game == null) ? '' : game.isStarted ? 'Resume' : 'Start';
  }
  
  bool get _isReady => gameMatch != null && playerId != null;
  
}