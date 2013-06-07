part of tilebasedwordsearch;

class AchievementType {
  static const SEVEN_LETTER_WORD = const AchievementType._(0);
  static const EIGHT_LETTER_WORD = const AchievementType._(1);
  static const NINE_LETTER_WORD = const AchievementType._(2);
  static const TEN_LETTER_WORD = const AchievementType._(3);

  static get values => const [SEVEN_LETTER_WORD, EIGHT_LETTER_WORD,
                              NINE_LETTER_WORD, TEN_LETTER_WORD];
  final int value;
  const AchievementType._(this.value);
}

class Achievement {
  final String achievementId;
  final AchievementType achievementType;

  Achievement(this.achievementId, this.achievementType);

  Future<AchievementIncrementResponse> submitAchievment(Player player, int score) {
    return player.gamesclient.achievements.increment(achievementId, score);
  }
}