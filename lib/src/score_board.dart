part of tilebasedwordsearch;

/**
 *
 */
class ScoreBoard {
  String leaderBoardId;
  ScoreType scoreType;

  ScoreBoard(this.leaderBoardId, this.scoreType);

  Future<PlayerScoreResponse> submitScore(Player player, int score) {
    return player.gamesclient.scores.submit(leaderBoardId, score);
  }
}