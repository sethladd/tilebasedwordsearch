part of tilebasedwordsearch;

/**
 * Suitable for storage and retrieval.
 */
class GameScore {
  DateTime when;
  int score;
  String opponentName;
  
  GameScore(this.when, this.score, this.opponentName);
  
  Map toJson() {
    return {'when': when.toString(), 'score': score, opponentName: opponentName};
  }
}