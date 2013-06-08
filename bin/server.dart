library hello_static;

import "package:logging/logging.dart";
import "package:start/start.dart";
import 'package:tilebasedwordsearch/persistable.dart' as db;
import 'package:crypto/crypto.dart';

import 'dart:io';
import 'dart:math';

// Needs to be the same one used on the client side.
final String CLIENT_ID = "";
final String CLIENT_SECRET = "";

final String TOKENINFO_URL = "https://www.googleapis.com/oauth2/v1/tokeninfo";
final String TOKEN_ENDPOINT = 'https://accounts.google.com/o/oauth2/token';
final String TOKEN_REVOKE_ENDPOINT = 'https://accounts.google.com/o/oauth2/revoke';

final Random random = new Random();
final Logger serverLogger = new Logger("server");

void main() {
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
    serverLogger.fine('DB connected, now starting up web server');
    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
      serverLogger.fine('HTTP server started');
      app.get('/games/:id').listen(getGame);
      app.post('/games').listen(createGame);
      // /index.html hanlders
      app.get('/').listen(getIndex);
      app.get('/index').listen(getIndex);
      app.get('/index.html').listen(getIndex);
    });
  })
  .catchError((e) => serverLogger.fine("error: $e"));
}

getIndex(Request req) {
  serverLogger.fine("getIndex");

}

getGame(Request req) {
  var id = req.params['id'];
  db.load(id, 'game').then((Map row) {
    if (row == null) {
      req.response.status(HttpStatus.NOT_FOUND);
      req.response.close();
    } else {
      req.response.json(row);
    }
  });
}

createGame(Request req) {
  HttpBodyHandler.processRequest(req.input)
    .then((HttpBody body) {

    })
    .catchError((e) {
      req.response
          ..status(500)
          ..close();
    });
}

//createCat(Request req, Response res) {
//  HttpBodyHandler.processRequest(req.input)
//    .then((HttpBody body) {
//      return body.body['name'];
//    })
//    .then((name) => db.execute('INSERT INTO cats (name) VALUES (@n)', {'n':name}))
//    .then((_) {
//      res
//       ..status(201)
//       ..close();
//    })
//    .catchError((e) {
//      print("Error with insert: $e");
//      res
//        ..status(500)
//        ..close();
//    });
//}

/**
 * Logger configuration.
 */
_setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord logRecord) {
    StringBuffer sb = new StringBuffer();
    sb
    ..write(logRecord.time.toString())..write(":")
    ..write(logRecord.loggerName)..write(":")
    ..write(logRecord.level.name)..write(":")
    ..write(logRecord.sequenceNumber)..write(": ")
    ..write(logRecord.message.toString());
    print(sb.toString());
  });
}

/**
 * Creating state token based on random number.
 */
String _createStateToken() {
  StringBuffer stateTokenBuffer = new StringBuffer();
  new MD5()
  ..add(random.nextDouble().toString().codeUnits)
  ..close().forEach((int s) => stateTokenBuffer.write(s.toRadixString(16)));
  String stateToken = stateTokenBuffer.toString();
  return stateToken;
}