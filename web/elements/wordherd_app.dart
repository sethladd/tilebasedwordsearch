import 'package:polymer/polymer.dart';
import 'package:route/client.dart';

@CustomTag('wordherd-app')
class WordherdApp extends PolymerElement {
  @observable String view = 'home';
  
  void created() {
    super.created();
    
    // TODO put this into a custom element, once auto-node finding works from expressions
    var router = new Router(useFragment: true)
    ..addHandler(new UrlPattern(r'(.*)/index.html'), (_) => view = 'home')
    ..addHandler(new UrlPattern(r'(.*)#/game'), (_) => view = 'game')
    ..listen();
  }
}