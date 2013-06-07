part of tilebasedwordsearch;

class ScoreType {
  static const HIGH_SCORE = const ScoreType._(0);
  static const MOST_NUMBER_OF_WORDS = const ScoreType._(1);

  static get values => const [HIGH_SCORE, MOST_NUMBER_OF_WORDS];
  final int value;
  const ScoreType._(this.value);
}

class Player {
  // Simple Authentication class that takes the token from the Sign-in button
  SimpleOAuth2 authenticationContext;

  // Dart Client Library for the Google+ API
  Plus plusclient;

  // Dart Client Library for the Game Play Services API
  Games gamesclient;

  // Collection of score boards on Play Services.
  List<ScoreBoard> scoreBoards;

  // Collection of achievements on Play Services.
  List<Achievement> achievement;

  Player() {
    authenticationContext = new SimpleOAuth2(null);
    plusclient = new Plus(authenticationContext);
    gamesclient = new Games(authenticationContext);
    scoreBoards = new List<ScoreBoard>();
    achievement = new List<Achievement>();
  }

  void signedIn(SimpleOAuth2 authenticationContext) {
    plusclient.makeAuthRequests = true;
    gamesclient.makeAuthRequests = true;
    print("Player is signed in");
    currentPanel = 'main';
  }

  void signedOut() {
    print("Player is signed out");
    currentPanel = 'login';
  }

  Future<List<Person>> friends({String orderBy: 'alphabetical',
    int maxResults: 20}) {
    return plusclient.people.list('me', 'visible', orderBy: orderBy,
        maxResults: maxResults).then((PeopleFeed pf) => pf.items);
  }

  void submitScore(ScoreType scoreType, int score) {
    scoreBoards
    .where((ScoreBoard sb) => sb.scoreType == scoreType)
    .forEach((ScoreBoard sb) => sb.submitScore(this, score));
  }

  List<Future<AchievementIncrementResponse>> submitAchievement(AchievementType achievementType, int score) {
    achievement
    .where((Achievement ac) => ac.achievementType == achievementType)
    .map((Achievement ac) => ac.submitAchievment(this, score)).toList();
  }

}