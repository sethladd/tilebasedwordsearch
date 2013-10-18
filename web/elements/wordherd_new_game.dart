import 'package:polymer/polymer.dart';
import "package:google_plus_v1_api/plus_v1_api_browser.dart";
import 'dart:html';
import 'dart:async';
import 'package:logging/logging.dart';

final Logger log = new Logger('WordherdNewGame');

@CustomTag('wordherd-new-game')
class WordherdNewGame extends PolymerElement {
  final List friends = toObservable([]);
  
  void created() {
    super.created();
    
    Plus plus = document.body.query('google-signin').xtag.plusClient;
    
    log.fine('Finding friends');
    
    _loadFriends(plus).then((List<Person> people) {
      log.fine('Found friends');
      friends.addAll(people);
    })
    .catchError((e) => log.severe('Problem finding friends: $e'));
  }
  
  Future<List<Person>> _loadFriends(Plus plus, {String orderBy: 'alphabetical',
    int maxResults: 20}) {
    return plus.people.list('me', 'visible', orderBy: orderBy,
        maxResults: maxResults).then((PeopleFeed pf) => pf.items);
  }
}