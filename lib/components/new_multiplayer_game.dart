import 'package:web_ui/web_ui.dart';
import 'package:tilebasedwordsearch/shared_html.dart';
import 'dart:html';
import 'dart:json' as json;

// TODO: use real routing, don't import the entire app
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart' as app;

class NewMultiplayerGame extends WebComponent {
  List<Player> players = toObservable([]);
  List<Game> games;
  
  created() {
    HttpRequest.request('/multiplayer_games/new').then((HttpRequest request) {
      List<Map> datas = json.parse(request.responseText);
      players.addAll(datas.map((d) => new Player.fromPersistence(d['id'], d)));
    })
    .catchError((e) => print('Did not load players for multiplayer game: $e'));
  }
  
  createNewMatch(String opponentGplusId) {
    HttpRequest.request('/multiplayer_games', method: 'POST',
        sendData: app.encodeMap({'opponentGplusId': opponentGplusId}),
        requestHeaders: {'Content-Type': 'application/x-www-form-urlencoded'})
      .then((request) {
        Map data = json.parse(request.responseText);
        TwoPlayerMatch match = new TwoPlayerMatch.fromPersistence(data['id'], data);
        // TODO wrap in a transaction
        return match.store().then((_) {
          app.newGame(match: match);
        });
        
      })
      .catchError((e) => print('Error creating new multiplayer game: $e'));
  }
}