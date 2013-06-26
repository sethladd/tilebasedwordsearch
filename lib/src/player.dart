part of tilebasedwordsearch;

class ScoreType {
  static const HIGH_SCORE = const ScoreType._(0);
  static const MOST_NUMBER_OF_WORDS = const ScoreType._(1);

  static get values => const [HIGH_SCORE, MOST_NUMBER_OF_WORDS];
  final int value;
  const ScoreType._(this.value);
}

class HighScoreInfo {
  String displayName;
  int scoreRank;
  int scoreValue;
  String timeSpan;
  HighScoreInfo(this.displayName,
                this.scoreRank,
                this.scoreValue,
                this.timeSpan);
}

// XXX: What is the ID that I can use in the database?
class Player {
  final Logger _playerLogger = new Logger("Player");
  Map _authResult;

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

  // The ID of the player which corresponds to the g+ id
  // and is only available after signedIn has been called.
  String id;

  @observable String displayName = "";
  @observable String imgUrl = "";

  List<HighScoreInfo> allTimeHighScores = toObservable(<HighScoreInfo>[]);

  @observable bool isConnected = false;

  Player() {
    authenticationContext = new SimpleOAuth2(null);
    plusclient = new Plus(authenticationContext);
    gamesclient = new Games(authenticationContext);
    scoreBoards = new List<ScoreBoard>();
    achievement = new List<Achievement>();
  }

  void signedIn(SimpleOAuth2 authenticationContext, [Map authResult]) {
    if (authResult != null) {
      _authResult = authResult;
    }

    plusclient.makeAuthRequests = true;
    gamesclient.makeAuthRequests = true;
    clientLogger.info("Player is signed in client side");

    plusclient.people.get('me').then((Person person) {
      // Connect to the server with offline token.
      id = person.id;
      displayName = person.displayName;
      imgUrl = person.image.url;
      isConnected = true;
      _connectServer(id);
    });

    currentPanel = 'main';
  }

  void _connectServer(String gplusId) {
    clientLogger.fine("gplusId = $gplusId");
    var stateToken = (query("meta[name='state_token']") as MetaElement).content;
    String url = "${window.location.href}connect?state_token=${stateToken}&gplus_id=${gplusId}";
    clientLogger.fine(url);
    HttpRequest.request(url, method: "POST", sendData: JSON.stringify(_authResult),
        onProgress: (ProgressEvent e) {
          clientLogger.fine("ProgressEvent ${e.toString()}");
        }
    )
    .then((HttpRequest request) {
      clientLogger.fine("connected from POST METHOD");
      if (request.status == 401) {
        clientLogger.fine("request.responseText = ${request.responseText}");
        return;
      }

//      HttpRequest.getString("${window.location.href}people").then((String data) {
//        clientLogger.fine("/people = $data");
//        Map peopleData = JSON.parse(data);
//        showPeople(peopleData);
//      });
    }).catchError((error) {
      clientLogger.fine("POST $url error ${error.toString()}");
    });
  }

  void signedOut() {
    print("Player is signed out");
    isConnected = false;
  }

  Future<List<Person>> friends({String orderBy: 'alphabetical',
    int maxResults: 20}) {
    return plusclient.people.list('me', 'visible', orderBy: orderBy,
        maxResults: maxResults).then((PeopleFeed pf) => pf.items);
  }

  void submitScore(ScoreType scoreType, int score) {
    scoreBoards
    .where((ScoreBoard sb) => sb.scoreType == scoreType)
    .forEach((ScoreBoard sb) {
      sb.submitScore(this, score)
      .then((PlayerScoreResponse playerScoreResponse) => _playerLogger.fine("playerScoreResponse = $playerScoreResponse"))
      .catchError((e) => _playerLogger.fine("Not able to submit score: $e"));

    });
  }

  List<Future<AchievementIncrementResponse>> submitAchievement(AchievementType achievementType, int score) {
    achievement
    .where((Achievement ac) => ac.achievementType == achievementType)
    .map((Achievement ac) => ac.submitAchievment(this, score)).toList();
  }

  refreshHighScoreLeaderboard() {
    if (gamesclient == null) return;

    ScoreBoard highScoreBoard = scoreBoards
    .singleWhere((ScoreBoard sb) => sb.scoreType == ScoreType.HIGH_SCORE);

    gamesclient.scores.listWindow(highScoreBoard.leaderBoardId,
        "PUBLIC", "ALL_TIME", maxResults: 25)
        .then((LeaderboardScores leaderboardScores) {

          allTimeHighScores.clear();
          leaderboardScores.items.forEach((LeaderboardEntry lbe) {
            _playerLogger.fine("${lbe.player.displayName} ${lbe.scoreRank} ${lbe.scoreValue} ${lbe.timeSpan}");
            allTimeHighScores.add(new HighScoreInfo(lbe.player.displayName, lbe.scoreRank, lbe.scoreValue, lbe.timeSpan));
          });

        }).catchError((e) => _playerLogger.fine("Not able to refresh high scores: $e"));
  }
}