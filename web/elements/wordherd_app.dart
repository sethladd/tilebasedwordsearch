import 'package:polymer/polymer.dart';  // XXX DO NOT USE SHOW HERE
import 'package:route/client.dart' show Router, UrlPattern;
import 'dart:html' show CustomEvent, HttpRequest, Node, document;
import 'dart:async' show Future;
import 'google_signin.dart' show GoogleSignin;
import "package:google_plus_v1_api/plus_v1_api_client.dart" show Person;
import "package:google_plus_v1_api/plus_v1_api_browser.dart" show Plus;
import 'package:logging/logging.dart' show Logger;
import 'package:wordherd/shared_html.dart' show Player;

final Logger log = new Logger('WordherdApp');

@CustomTag('wordherd-app')
class WordherdApp extends PolymerElement {
  @observable String view = 'home';
  final Map<String, String> pathParts = toObservable({});

  @observable bool playerSignedIn = false;
  @observable Person person;
  @observable Player player;

  final UrlPattern matchPath = new UrlPattern(r'(.*)#/match/(\d+)');
  final UrlPattern soloGamePath = new UrlPattern(r'(.*)#/sologame/(.*)');

  // TODO move this into enteredView ?
  WordherdApp.created() : super.created() {

    // TODO put this into a custom element, once auto-node finding works from expressions
    var router = new Router(useFragment: true)
    ..addHandler(new UrlPattern(r'(.*)/index.html'), (_) => view = 'home')
    ..addHandler(new UrlPattern(r'(.*)#/'), (_) => view = 'home')

    // TODO check in on https://github.com/dart-lang/route/issues/52
    ..addHandler(matchPath, (String path) {
      view = 'match';
      pathParts
        ..clear()
        ..['matchId'] = matchPath.parse(path)[1];
    })
    ..addHandler(new UrlPattern(r'(.*)#/game'), (_) => view = 'game')
    ..addHandler(soloGamePath, (String path) {
      view = 'sologame';
      pathParts
        ..clear()
        ..['gameId'] = soloGamePath.parse(path)[1];
    })
    ..addHandler(new UrlPattern(r'(.*)#/sologames'), (_) => view = 'sologames')
    ..addHandler(new UrlPattern(r'(.*)#/newgame'), (_) => view = 'newgame')
    ..addHandler(new UrlPattern(r'(.*)#/matches'), (_) => view = 'matches')
    ..addHandler(new UrlPattern(r'(.*)#/admin/matches'), (_) => view = 'admin/matches')
    ..listen();

    // TODO once https://code.google.com/p/dart/issues/detail?id=14210
    // is fixed, I can put this into a declarative event handler
    document.body.on['signincomplete'].listen((CustomEvent e) {
      log.fine('Received the signingcomplete event');
      Node target = e.target;
      playerSignedIn = true;
      Plus plus = ((target as GoogleSignin).plusClient);
      _registerPlayer(plus);
    });
  }

  Future _registerPlayer(Plus plus) {
    return plus.people.get('me').then((Person p) {
      person = p;
      return HttpRequest.postFormData('/register', {'gplus_id': p.id, 'name': p.displayName})
         .then((_) => log.fine('player registered with server'))
         .catchError((e) {
           log.severe('Error when registering with server: $e');
         });
    })
    .catchError((e) => log.severe('Could not get person data from g+: $e'));
  }

}
