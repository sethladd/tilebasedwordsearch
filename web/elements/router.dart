import 'package:polymer/polymer.dart';
import 'package:route/client.dart';

@CustomTag('r-outer')
class RouterElement extends PolymerElement {
  
  void created() {
    super.created();
    
    var router = new Router(useFragment: true)
    ..addHandler(new UrlPattern(r'(.*)/index.html'), (_) => view = 'home')
    ..addHandler(new UrlPattern(r'(.*)#/game'), (_) => view = 'game')
    ..listen();
  }
}