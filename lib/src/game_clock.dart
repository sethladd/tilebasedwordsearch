part of tilebasedwordsearch;

class GameClock {
  static const int DEFAULT_GAME_LENGTH = 10;
  final game_loop.GameLoop gameLoop;

  bool shouldPause = false;
  int gameLength = DEFAULT_GAME_LENGTH;
  game_loop.Timer timer;    // Will be an instance of game_loop's Timer class
  
  @observable
  int secondsRemaining = DEFAULT_GAME_LENGTH;
  
  GameClock(game_loop.GameLoop this.gameLoop, {this.gameLength:DEFAULT_GAME_LENGTH}) {
    if (gameLength != null) {
      secondsRemaining = gameLength;
    }
  }
  
  tick(game_loop.GameLoopTimer _) {
    secondsRemaining--;
    print(secondsRemaining);
//    if (!shouldPause && (secondsRemaining > 0)) {
//      gameLoop.addTimer(tick, 1.0); // 1 second timer
//    }
  }
  
  start() {
    shouldPause = false;
    gameLoop.addTimer(tick, 1.0);   // 1 second timer
  }
  
  stop() {
    timer.cancel();
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