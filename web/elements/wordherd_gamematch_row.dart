import 'package:polymer/polymer.dart' show CustomTag, Observable, Polymer, observable, published, onPropertyChange;
import 'dart:html' show TableRowElement;
import 'package:wordherd/shared_html.dart' show GameMatch, Game;

@CustomTag('wordherd-gamematch-row')
class WordherdGamematchRow extends TableRowElement with Polymer, Observable {
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
  
  // TODO create a game-match custom element and put these in there
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