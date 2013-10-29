import 'package:polymer/polymer.dart';
import 'package:serialization/serialization.dart';
import 'package:wordherd/shared_html.dart';
import 'dart:html';
import 'dart:convert' show JSON;
import 'package:logging/logging.dart';

final Serialization serializer = new Serialization();
final Logger log = new Logger('AdminMatches');

@CustomTag('admin-matches')
class AdminMatches extends PolymerElement {
  final List<GameMatch> gameMatches = toObservable([]);
  
  AdminMatches.created() : super.created();
  
  void enteredView() {
    super.enteredView();
    HttpRequest.request('/matches').then((HttpRequest req) {
      List<GameMatch> allMatches = serializer.read(JSON.decode(req.responseText));
      gameMatches.addAll(allMatches);
    })
    .catchError((e, stackTrace) {
      log.severe('Error pulling all matches: $e');
    });
  }
  
  void saveMatch(Event e, var detail, Node target) {
    String matchId = (target as Element).dataset['id'];
    GameMatch theMatch = gameMatches.firstWhere((m) => m.id == matchId);
    String data = JSON.encode(serializer.write(theMatch));
    HttpRequest.request('/admin/matches/update',
        method: 'POST',
        withCredentials: true,
        requestHeaders: {'Content-Type': 'application/json'},
        sendData: data).then((HttpRequest resp) {
          log.fine('Match $matchId is updated');
        })
        .catchError((e) => log.severe('Error updating match: $e'));
  }
}