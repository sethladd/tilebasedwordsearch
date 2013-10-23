import 'package:polymer/polymer.dart';
import 'package:wordherd/shared_html.dart';
import 'dart:html';
import 'package:logging/logging.dart';
import 'package:serialization/serialization.dart';
import 'dart:convert' show JSON;

final Logger log = new Logger('WordherdMatches');
final Serialization serializer = new Serialization();

@CustomTag('wordherd-matches')
class WordherdMatches extends PolymerElement {
  @observable String playerId;
  final List<Match> gameMatches = toObservable([]);
  @published String gameserverurl; // TODO move back to camel case once bug is fixed
  
  void inserted() {
    super.inserted();
    
    Person me = (document.body.query('wordherd-app').xtag as WordherdApp).person;
    playerId = me.id;
    
    HttpRequest.request('$gameserverurl/matches/me', withCredentials: true)
      .then((HttpRequest contents) {
        List<Match> _matches = serializer.read(JSON.decode(contents.responseText));
        gameMatches.addAll(_matches);
      })
      .catchError((e) => log.severe('Did not load matches: $e'));
  }
}