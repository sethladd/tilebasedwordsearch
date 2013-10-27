part of client_game;

class GameClock extends Observable {
  final Logger _log = new Logger('GameClock');
  static const int DEFAULT_GAME_LENGTH = 70; // # of seconds in a game
  final GameLoop gameLoop;

  bool shouldPause = false;
  int gameLength = DEFAULT_GAME_LENGTH;
  final Completer _allDone = new Completer();
  
  @observable
  int secondsRemaining = DEFAULT_GAME_LENGTH;
  
  GameClock(GameLoop this.gameLoop, {this.gameLength:DEFAULT_GAME_LENGTH}) {
    if (gameLength != null) {
      secondsRemaining = gameLength;
    }
  }

  Future get whenDone => _allDone.future;
  
  tick(GameLoopTimer _) {
    if (!shouldPause) {
      secondsRemaining--;
      if (secondsRemaining > 0) {
        gameLoop.addTimer(tick, 1.0); // 1 second timer
      } else {
        _allDone.complete(true);
        _log.fine('Timer is done');
      }
    }
  }
  
  start() {
    shouldPause = false;
    gameLoop.addTimer(tick, 1.0);   // 1 second timer
  }
  
  stop() {
    shouldPause = true;
    secondsRemaining = 0;
    _allDone.complete(true);
    _log.fine('forced stop');
  }
  
  pause() {
    shouldPause = true;
  }
  
  restart() {
    shouldPause = false;
    tick(null);
  }
  
  addTime(int numSeconds) {
    secondsRemaining += numSeconds;
  }
}