import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:serialization/serialization.dart';
import 'package:wordherd/shared_html.dart' as wh show Match;

final Serialization serializer = new Serialization();

@CustomTag('wordherd-match')
class WordherdMatch extends PolymerElement {
  @published String matchId;
  @observable wh.Match match;
  
  WordherdMatch.created() : super.created();
  
  void ready() {
    super.ready();
    
    HttpRequest.request('/match/$matchId', method: 'GET', withCredentials: true)
    .then((HttpRequest request) {
      Match match = serializer.read(JSON.decode(request.responseText));
    });
  }
}