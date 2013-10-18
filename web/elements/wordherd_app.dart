import 'package:polymer/polymer.dart';
import 'package:route/client.dart';
import 'dart:html';
import 'google_signin.dart';

@CustomTag('wordherd-app')
class WordherdApp extends PolymerElement {
  @observable String view = 'home';
  @observable bool playerSignedIn = false;
  
  void created() {
    super.created();
    
    // TODO put this into a custom element, once auto-node finding works from expressions
    var router = new Router(useFragment: true)
    ..addHandler(new UrlPattern(r'(.*)/index.html'), (_) => view = 'home')
    ..addHandler(new UrlPattern(r'(.*)#/game'), (_) => view = 'game')
    ..addHandler(new UrlPattern(r'(.*)#/newgame'), (_) => view = 'newgame')
    ..listen();
    
    // TODO once https://code.google.com/p/dart/issues/detail?id=14210
    // is fixed, I can put this into a declarative event handler
    document.body.on['signincomplete'].listen((CustomEvent e) {
      Node target = e.target; 
      playerSignedIn = true;
      print(((target as Element).xtag as GoogleSignin).plusClient);
    });
  }
}