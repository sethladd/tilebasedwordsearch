import 'package:web_ui/web_ui.dart';
import 'package:tilebasedwordsearch/shared_html.dart';
import 'dart:html';
import 'dart:json' as json;

class NewMultiplayerGame extends WebComponent {
  List<Player> players = toObservable([]);
  
  created() {
    HttpRequest.request('/multiplayer_games/new').then((HttpRequest request) {
      List<Map> data = json.parse(request.responseText);
      players.addAll(data.map((d) => new Player.fromPersistence(d)));
    })
    .catchError((e) => print('Did not load players for multiplayer game: $e'));
  }
}