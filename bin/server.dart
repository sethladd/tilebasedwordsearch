  library hello_static;

import 'package:logging/logging.dart';
import "package:start/start.dart";
import 'package:tilebasedwordsearch/shared_io.dart';
import 'package:tilebasedwordsearch/persistable_io.dart' as db;

import 'dart:io';
import 'dart:async';

Logger log = new Logger('server');

void main() {

  log.onRecord.listen((LogRecord r) {
    print('[${r.level}] [${r.loggerName}] [${r.time}] - ${r.message}');
  });
  
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
    var path = new Path(new Options().script).directoryPath.append('..').append('boardgen').append('dense1000.txt');
    return new File.fromPath(path).readAsString();
  })
  .then((String lines) {
    initBoards(lines);
  })
  .then((_) {
    log.info('DB connected, now starting up web server');
    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
      log.info('HTTP server started on port $port');
      app.get('/games/:id').listen(getGame);
      app.post('/games/:id').listen(updateGame);
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
      req.response.json(game.toJson());
    }
  })
  .catchError((e) {
    log.severe('Error from getGame: $e');
    req.response
      ..status(500)
      ..close();
  });
}

updateGame(Request req) {
  log.info('updateGame');
  Game game;
  var id = int.parse(req.params['id']);
  db.Persistable.load(id, Game).then((Game g) {
    if (g == null) {
      return new Future.error('NOT FOUND');
    } else {
      game = g;
      return HttpBodyHandler.processRequest(req.input);
    }
  })
  .then((HttpBody body) {
    var map = body.body as Map;
    game.update(map);
    return game.store();
  })
  .then((_) {
    req.response
      ..status(HttpStatus.OK)
      ..close();
  })
  .catchError((e) {
    req.response
      ..status(HttpStatus.NOT_FOUND)
      ..close();
  }, test: (e) => e == 'NOT FOUND')
  .catchError((e) {
    log.severe('Error updating: $e');
    req.response
      ..status(500)
      ..close();
  });

}

createGame(Request req) {
  HttpBodyHandler.processRequest(req.input)
    .then((HttpBody body) {
      var game = new Game()
        ..board = getRandomBoard().board;
      return game.store().then((_) {
        req.response
            ..status(HttpStatus.CREATED)
            ..close();
      });
    })
    .catchError((e) {
      log.severe('Error from createGame: $e : ${getAttachedStackTrace(e)}');
      req.response
          ..status(500)
          ..close();
    });
}
