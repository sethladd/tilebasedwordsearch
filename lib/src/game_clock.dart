part of client_game;

class GameClock extends Observable {
  final Logger _log = new Logger('GameClock');
  final GameLoop gameLoop;

  bool shouldPause = false;
  int _gameLength = Game.DEFAULT_GAME_LENGTH;
  final Completer _allDone = new Completer();

  final StreamController<int> _ticksStream = new StreamController();

  @observable
  int secondsRemaining = Game.DEFAULT_GAME_LENGTH;

  GameClock(GameLoop this.gameLoop, {int gameLength}) {
    if (gameLength != null) {
      secondsRemaining = gameLength;
      _gameLength = gameLength;
    }
  }

  Future get whenDone => _allDone.future;

  int get gameLength => _gameLength;

  tick(GameLoopTimer _) {
    if (!shouldPause) {
      secondsRemaining--;
      if (secondsRemaining > 0) {
        gameLoop.addTimer(tick, 1.0); // 1 second timer
        _ticksStream.add(secondsRemaining);
      } else {
        _allDone.complete(true);
        _log.fine('Timer is done');
      }
    }
  }

  // A stream of seconds remaining.
  Stream<int> get onTimeRemaning => _ticksStream.stream;

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