part of tilebasedwordsearch;

class GameClock {
  static const int DEFAULT_GAME_LENGTH = 10;
  static const Duration oneSecond = const Duration(seconds:1);
  static const Duration defaultGameLength = const Duration(seconds:DEFAULT_GAME_LENGTH);
  
  @observable
  int secondsRemaining = DEFAULT_GAME_LENGTH;
  
  Timer timer;
  Duration gameLength = defaultGameLength;
  
  GameClock({this.gameLength});
  
  // XXX: Use DateTime and single Timer fires to correct for imprecise timer firing?
  start() {
    timer = new Timer.repeating(oneSecond, (_) {
      secondsRemaining -= 1;
      if (secondsRemaining <= 0) {
        timer.cancel();
      }
      print(secondsRemaining);
    });
  }
  
  stop() {
    timer.cancel();
  }
  
  pause() {
    timer.cancel();
  }
  
  restart() {
    start();
  }
  
  addTime(int numSeconds) {
    secondsRemaining += numSeconds;
  }
}

main() {
  var clock = new GameClock();
  clock.start();
  print(clock.secondsRemaining);
  clock.addTime(5);
  print(clock.secondsRemaining);
}