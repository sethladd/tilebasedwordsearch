part of shared;

/**
 * We don't have fancy _ to camel case naming working yet. So just
 * use the database column names for now.
 */
class Game extends Object with Persistable {
  String board;
  
  /**
   * How to bind player in here? I'm assuming it's an ID.
   */
  int p1_id;
  int p2_id;
  
  int p1_score;
  int p2_score;
  
  /**
   * Comma-delineated list of words.
   */
  String p1_words;
  String p2_words;
  
  DateTime last_played;
  
  Game();
  
  Map toJson() {
    return {
      'board': board,
      'p1_id': p1_id,
      'p2_id': p2_id,
      'p1_score': p1_score,
      'p2_score': p2_score,
      'p1Words': p1_words,
      'p2_words': p2_words,
      'last_played': last_played
    };
  }
  
  List<String> get p1Words => p1_words.split(',');
  
  List<String> get p2Words => p2_words.split(',');
}