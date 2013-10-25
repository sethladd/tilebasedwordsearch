part of client_game;

class GameClock {
  static const int DEFAULT_GAME_LENGTH = 70; // # of seconds in a game
  final GameLoop gameLoop;

  bool shouldPause = false;
  int gameLength = DEFAULT_GAME_LENGTH;
  Completer allDone = new Completer();
  
  @observable
  int secondsRemaining = DEFAULT_GAME_LENGTH;
  
  GameClock(GameLoop this.gameLoop, {this.gameLength:DEFAULT_GAME_LENGTH}) {
    if (gameLength != null) {
      secondsRemaining = gameLength;
    }
  }

  
  tick(GameLoopTimer _) {
    if (!shouldPause) {
      secondsRemaining--;
      if (secondsRemaining > 0) {
        gameLoop.addTimer(tick, 1.0); // 1 second timer
      } else {
        allDone.complete(true);
        print('DONE!');
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
    allDone.complete(true);
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