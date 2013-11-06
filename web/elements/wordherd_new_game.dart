import 'package:polymer/polymer.dart';
import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:logging/logging.dart';
import 'package:wordherd/shared_html.dart';
import 'package:serialization/serialization.dart';
import 'package:google_plus_v1_api/plus_v1_api_client.dart' show Person;
import 'wordherd_app.dart';

final Logger log = new Logger('WordherdNewGame');
final Serialization _serializer = new Serialization();

@CustomTag('wordherd-new-game')
class WordherdNewGame extends PolymerElement {
  final List<Player> friends = toObservable([]);
  @observable bool loadDataComplete = false;
  WordherdNewGame.created() : super.created();

  // Looks like inserted is when all attributes are ready (??)
  // TODO ready() might be a better callback here
  void enteredView() {
    super.enteredView();

    _loadFriendsToPlay().then((List<Player> people) {
      log.fine('Found friends: $people');
      friends.addAll(people);
    })
    .catchError((e) => log.severe('Problem finding friends: $e'))
    .whenComplete(() => loadDataComplete = true);
  }

  Future<List<Player>> _loadFriendsToPlay() {
    log.fine('Finding friends to play');
    return HttpRequest.request('/friendsToPlay',
        withCredentials: true, method: 'GET') // TODO accept json
      .then((HttpRequest response) {
        Map json = JSON.decode(response.responseText) as Map;
        return _serializer.read(json);
      });
  }

  void createMatch(Event e, var detail, Node target) {
    log.fine('here in create');
    Person me = (document.body.querySelector('wordherd-app') as WordherdApp).person;
    String friendGplusId = (target as Element).dataset['friend-id'];
    String friendName = (target as Element).dataset['friend-name'];
    Map data = {'p1_id': me.id, 'p1_name': me.displayName, 'p2_id': friendGplusId, 'p2_name': friendName};
    log.fine('Creating match with $data');
    HttpRequest.postFormData('/matches', data, withCredentials: true)
      .then((HttpRequest response) {
        String location = response.getResponseHeader('Location');
        log.fine('Location to new match is $location');
        String matchId = new RegExp(r'/matches/(\d+)').firstMatch(location).group(1);
        log.fine('Match created with ID $matchId');

        // TODO: store the match locally?

        window.location.hash = '/matches';
      })
      .catchError((e) {
        log.severe('Could not create match: $e');
        // TODO display error
      });
  }

  // This is here to force MirrorsUsed to keep isEmpty
  bool get noFriends => friends.isEmpty;
}