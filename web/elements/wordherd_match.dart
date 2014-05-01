import 'package:polymer/polymer.dart';  // XXX DO NOT USE SHOW HERE
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:serialization/serialization.dart';
import 'package:wordherd/shared_html.dart' show Board, Game, GameMatch;
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
  @observable Game game;
  @observable Board board;

  WordherdMatch.created() : super.created();

  void ready() {
    super.ready();

    new PathObserver(this, 'game.isDone').changes.listen((_) {
      log.fine('Notified that game.isDone has changed');
      if (game.isDone) {
        syncGameToServer();
      }
    });
  }

  void enteredView() {
    super.enteredView();

    Person me = (document.body.querySelector('wordherd-app') as WordherdApp).person;
    playerId = me.id;

    log.fine('Getting match details for $matchId');

    HttpRequest.request('/matches/$matchId', method: 'GET', withCredentials: true)
    .then((HttpRequest request) {
      match = serializer.read(JSON.decode(request.responseText));
      game = match.myGame(playerId);
      board = match.board;
    })
    .catchError((e) => log.severe('Could not retrieve match for $matchId: $e'));
  }

  void syncGameToServer() {
    log.fine('Syncing game to server');
    HttpRequest.request('/matches/$matchId/game/$playerId',
        method: 'POST',
        withCredentials: true,
        requestHeaders: {'Content-Type': 'application/json'},
        sendData: JSON.encode(serializer.write(game)))
    .then((HttpRequest request) {
      log.fine('Game update sent to server');
    })
    .catchError((e, stackTrace) {
      log.severe('Did not sync game to server: $e $stackTrace');
    });
  }

  String get winningMsg {
    if (!match.isOver) {
      return "Waiting on partner";
    }
    if (match.winningId == playerId) {
      return "You Won!";
    } else {
      return "You Got Wrangled";
    }
  }
}