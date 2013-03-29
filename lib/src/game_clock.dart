part of tilebasedwordsearch;

class GameClock {
  static const int DEFAULT_GAME_LENGTH = 70;
  final game_loop.GameLoop gameLoop;

  bool shouldPause = false;
  int gameLength = DEFAULT_GAME_LENGTH;
  game_loop.GameLoopTimer timer;
  
  @observable
  String timeRemaining = "Not yet started";
  
  int secondsRemaining = DEFAULT_GAME_LENGTH;
  
  GameClock(game_loop.GameLoop this.gameLoop, {this.gameLength:DEFAULT_GAME_LENGTH}) {
    if (gameLength != null) {
      secondsRemaining = gameLength;
    }
    timeRemaining = formatTime(secondsRemaining);
  }
  
  String formatTime(int seconds) {
    if (seconds <= 0) return 'OUT OF TIME!!!!';
    
    int m = seconds ~/ 60;
    int s = seconds % 60;
    
    String minuteString = "";
    String secondString = "";

    if (m > 0) {
      minuteString = '${m.toString()}:';
      secondString = (s <= 9) ? '0$s' : '$s';
    } else {
      secondString = s.toString();
    }
    return '$minuteString$secondString';
  }
  
  tick(game_loop.GameLoopTimer _) {
    if (!shouldPause) {
      secondsRemaining--;
      timeRemaining = formatTime(secondsRemaining);
      if (secondsRemaining > 0) {
        gameLoop.addTimer(tick, 1.0); // 1 second timer
      }
    }
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