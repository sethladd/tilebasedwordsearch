import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:serialization/serialization.dart';
import 'package:wordherd/shared_html.dart' show Game, GameMatch;
import 'package:google_plus_v1_api/plus_v1_api_client.dart' show Person;
import 'wordherd_app.dart';
import 'package:logging/logging.dart' show Logger;

final Serialization serializer = new Serialization();
final Logger log = new Logger('WordherdMatch');

@CustomTag('wordherd-match')
class WordherdMatch extends PolymerElement {
  @published String matchId;
  @observable GameMatch match;
  @observable String playerId;
  @published String gameserverurl;
  @observable Game game;
  @observable Board board;
  
  WordherdMatch.created() : super.created();
  
  void enteredView() {
    super.enteredView();
    
    Person me = (document.body.querySelector('wordherd-app') as WordherdApp).person;
    playerId = me.id;

    log.fine('Getting match details for $matchId');
    
    HttpRequest.request('$gameserverurl/matches/$matchId', method: 'GET', withCredentials: true)
    .then((HttpRequest request) {
      match = serializer.read(JSON.decode(request.responseText));
    })
    .catchError((e) => log.severe('Could not retrieve match for $matchId: $e'));
  }
  
  void playGame(Event e, var detail, Node target) {
    log.fine('So you want to play a game');
    game = match.myGame(playerId);
    board = match.board;
  }
}