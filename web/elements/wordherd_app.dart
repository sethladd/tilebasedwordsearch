import 'package:polymer/polymer.dart';
import 'package:route/client.dart';
import 'dart:html';
import 'dart:async';
import 'google_signin.dart';
import "package:google_plus_v1_api/plus_v1_api_browser.dart";
import 'package:logging/logging.dart';
import 'package:wordherd/shared_html.dart';

final Logger log = new Logger('WordherdApp');

@CustomTag('wordherd-app')
class WordherdApp extends PolymerElement {
  @observable String view = 'home';
  @observable bool playerSignedIn = false;
  @observable Person person;
  @observable Player player;
  @published String gameserverurl;
  
  void created() {
    super.created();
    
    // TODO put this into a custom element, once auto-node finding works from expressions
    var router = new Router(useFragment: true)
    ..addHandler(new UrlPattern(r'(.*)/index.html'), (_) => view = 'home')
    ..addHandler(new UrlPattern(r'(.*)#/game'), (_) => view = 'game')
    ..addHandler(new UrlPattern(r'(.*)#/newgame'), (_) => view = 'newgame')
    ..addHandler(new UrlPattern(r'(.*)#/matches'), (_) => view = 'matches')
    ..listen();
    
    // TODO once https://code.google.com/p/dart/issues/detail?id=14210
    // is fixed, I can put this into a declarative event handler
    document.body.on['signincomplete'].listen((CustomEvent e) {
      log.fine('Received the signingcomplete event');
      Node target = e.target; 
      playerSignedIn = true;
      Plus plus = (((target as Element).xtag as GoogleSignin).plusClient);
      _registerPlayer(plus);
    });
  }
  
  Future _registerPlayer(Plus plus) {
    return plus.people.get('me').then((Person p) {
      person = p;
      return HttpRequest.postFormData('$gameserverurl/register', {'gplus_id': p.id, 'name': p.displayName})
         .then((_) => log.fine('player registered with server'))
         .catchError((e) {
           log.severe('Error when registering with server: $e');
         });
    })
    .catchError((e) => log.severe('Could not get person data from g+: $e'));
  }
  
}
