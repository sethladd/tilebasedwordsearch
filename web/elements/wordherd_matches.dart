import 'package:polymer/polymer.dart';
import 'package:wordherd/shared_html.dart' show Game, GameMatch;
import 'dart:html' show HttpRequest, document;
import 'package:logging/logging.dart' show Logger;
import 'package:serialization/serialization.dart' show Serialization;
import 'dart:convert' show JSON;
import 'wordherd_app.dart';
import 'package:google_plus_v1_api/plus_v1_api_client.dart' show Person;

final Logger log = new Logger('WordherdMatches');
final Serialization serializer = new Serialization();

@CustomTag('wordherd-matches')
class WordherdMatches extends PolymerElement {
  @observable String playerId;
  final List<GameMatch> gameMatches = toObservable([]);
  
  WordherdMatches.created() : super.created();
  
  @override
  void enteredView() {
    super.enteredView();
    
    Person me = (document.body.querySelector('wordherd-app') as WordherdApp).person;
    playerId = me.id;
    
    HttpRequest.request('/matches/me', withCredentials: true)
      .then((HttpRequest contents) {
        List<GameMatch> _matches = serializer.read(JSON.decode(contents.responseText));
        gameMatches.addAll(_matches);
      })
      .catchError((e) => log.severe('Did not load matches: $e'));
  }

}