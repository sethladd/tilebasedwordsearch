library hello_static;

import 'package:logging/logging.dart';
import "package:start/start.dart";
import 'package:tilebasedwordsearch/shared.dart';
import 'package:tilebasedwordsearch/persistable.dart' as db;

import 'dart:io';

Logger log = new Logger('server');

void main() {

  log.onRecord.listen((LogRecord r) => print('[${r.level}] [${r.loggerName}] [${r.time}] - ${r.message}'));
  
  var port = Platform.environment['PORT'] != null ?
      int.parse(Platform.environment['PORT'], onError: (_) => 8080) :
      8080;
  
  var dbUrl;
  if (Platform.environment['DATABASE_URL'] != null) {
    dbUrl = Platform.environment['DATABASE_URL'];
  } else {
    var user = Platform.environment['USER'];
    dbUrl = 'postgres://$user:@localhost:5432/$user';
  }
  
  db.init(dbUrl)
  .then((_) {
    log.info('DB connected, now starting up web server');
    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
      log.info('HTTP server started on port $port');
      app.get('/games/:id').listen(getGame);
      app.post('/games').listen(createGame);
    });
  })
  .catchError((e) => log.severe("error: $e"));
}

getGame(Request req) {
  var id = int.parse(req.params['id']);
  db.Persistable.load(id, Game).then((Game game) {
    if (game == null) {
      req.response
        ..status(HttpStatus.NOT_FOUND)
        ..close();
    } else {
      req.response.json(game.toMap());
    }
  })
  .catchError((e) {
    log.severe('Error from getGame: $e');
    req.response
      ..status(500)
      ..close();
  });
}

createGame(Request req) {
  HttpBodyHandler.processRequest(req.input)
    .then((HttpBody body) {
      var game = new Game();
      return game.store().then((_) {
        req.response.json(game.toMap());
      });
    })
    .catchError((e) {
      log.severe('Error from createGame: $e');
      req.response
          ..status(500)
          ..close();
    });
}
