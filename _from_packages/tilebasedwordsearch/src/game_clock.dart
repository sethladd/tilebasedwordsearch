part of tilebasedwordsearch;

class GameClock extends Observable  {
  static const int DEFAULT_GAME_LENGTH = 70; // # of seconds in a game
  final GameLoop gameLoop;

  bool shouldPause = false;
  int gameLength = DEFAULT_GAME_LENGTH;
  Completer allDone = new Completer();
  
  String __$timeRemaining = 'Not yet started';
  String get timeRemaining {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'timeRemaining');
    }
    return __$timeRemaining;
  }
  set timeRemaining(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'timeRemaining',
          __$timeRemaining, value);
    }
    __$timeRemaining = value;
  }
  
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
//# sourceMappingURL=game_clock.dart.map