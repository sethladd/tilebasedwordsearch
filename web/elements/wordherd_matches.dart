import 'package:polymer/polymer.dart' show CustomTag, PolymerElement, observable, published, toObservable;
import 'package:wordherd/shared_html.dart' as wh show Match;
import 'dart:html' show HttpRequest, document;
import 'package:logging/logging.dart' show Logger;
import 'package:serialization/serialization.dart' show Serialization;
import 'dart:convert' show JSON;
import 'package:meta/meta.dart' show override;
import 'wordherd_app.dart';
import 'package:google_plus_v1_api/plus_v1_api_client.dart' show Person;

final Logger log = new Logger('WordherdMatches');
final Serialization serializer = new Serialization();

@CustomTag('wordherd-matches')
class WordherdMatches extends PolymerElement {
  @observable String playerId;
  final List<wh.Match> gameMatches = toObservable([]);
  @published String gameserverurl; // TODO move back to camel case once bug is fixed
  
  WordherdMatches.created() : super.created();
  
  @override
  void enteredView() {
    super.enteredView();
    
    Person me = (document.body.querySelector('wordherd-app') as WordherdApp).person;
    playerId = me.id;
    
    HttpRequest.request('$gameserverurl/matches/me', withCredentials: true)
      .then((HttpRequest contents) {
        List<wh.Match> _matches = serializer.read(JSON.decode(contents.responseText));
        gameMatches.addAll(_matches);
      })
      .catchError((e) => log.severe('Did not load matches: $e'));
  }
}