part of tilebasedwordsearch;

class GameClock {
  static const int DEFAULT_GAME_LENGTH = 70; // # of seconds in a game
  final GameLoop gameLoop;

  bool shouldPause = false;
  int gameLength = DEFAULT_GAME_LENGTH;
  Completer allDone = new Completer();
  
  @observable
  String timeRemaining = 'Not yet started';
  
  int secondsRemaining = DEFAULT_GAME_LENGTH;
  
  GameClock(GameLoop this.gameLoop, {this.gameLength:DEFAULT_GAME_LENGTH}) {
    if (gameLength != null) {
      secondsRemaining = gameLength;
    }
    timeRemaining = formatTime(secondsRemaining);
  }
  
  String formatTime(int seconds) {
    if (seconds <= 0) return '0'; // XXX ok for stop() case?
    
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
  
  tick(GameLoopTimer _) {
    if (!shouldPause) {
      secondsRemaining--;
      timeRemaining = formatTime(secondsRemaining);
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
    secondsRemaining == 0;
    timeRemaining = 'GAME OVER!';
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