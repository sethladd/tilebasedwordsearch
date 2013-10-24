import 'package:polymer/polymer.dart';

@CustomTag('wordherd-match')
class WordherdMatch extends PolymerElement {
  @published String matchId;
  
  WordherdMatch.created() : super.created();
}