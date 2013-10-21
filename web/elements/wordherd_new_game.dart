import 'package:polymer/polymer.dart';
import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:logging/logging.dart';
import 'package:wordherd/shared_html.dart';
import 'package:serialization/serialization.dart';
import 'package:google_plus_v1_api/plus_v1_api_browser.dart';
import 'wordherd_app.dart';

final Logger log = new Logger('WordherdNewGame');
final Serialization _serializer = new Serialization();

@CustomTag('wordherd-new-game')
class WordherdNewGame extends PolymerElement {
  final List<Player> friends = toObservable([]);
  @published String gameserverurl; // TODO move back to camel case once bug is fixed
  
  // Looks like inserted is when all attributes are ready (??)
  void inserted() {
    super.inserted();
    
    _loadFriendsToPlay().then((List<Player> people) {
      log.fine('Found friends: $people');
      friends.addAll(people);
    })
    .catchError((e) => log.severe('Problem finding friends: $e'));
  }
  
  Future<List<Player>> _loadFriendsToPlay() {
    log.fine('Finding friends to play');
    return HttpRequest.request('$gameserverurl/friendsToPlay',
        withCredentials: true, method: 'GET') // TODO accept json
      .then((HttpRequest response) {
        Map json = JSON.decode(response.responseText) as Map;
        return _serializer.read(json);
      });
  }
  
  void createMatch(Event e, var detail, Node target) {
    Person me = (document.body.query('wordherd-app').xtag as WordherdApp).person;
    String friendGplusId = (target as Element).dataset['friend'];
    Map data = {'p1_id': me.id, 'p2_id': friendGplusId};
    log.fine('Creating match with $data');
    HttpRequest.postFormData('$gameserverurl/matches', data, withCredentials: true)
      .then((HttpRequest response) {
        String location = response.getResponseHeader('Location');
        log.fine('Location to new match is $location');
        String matchId = new RegExp(r'/matches/(\d+)').firstMatch(location).group(1);
        log.fine('Match created with ID $matchId');
      })
      .catchError((e) {
        log.severe('Could not create match: $e');
        // TODO display error
      });
        
  }
}