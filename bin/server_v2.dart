import 'package:http_server/http_server.dart';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:route/server.dart';
import 'package:path/path.dart' as path;
import 'package:wordherd/persistable_io.dart' as db;
import 'package:wordherd/shared_io.dart';
import 'dart:convert';
import 'dart:async';

final Logger log = new Logger('Server');

configureLogger() {
  Logger.root.onRecord.listen((LogRecord logRecord) {
    StringBuffer sb = new StringBuffer();
    sb
    ..write(logRecord.time.toString())..write(":")
    ..write(logRecord.loggerName)..write(":")
    ..write(logRecord.level.name)..write(":")
    ..write(logRecord.sequenceNumber)..write(": ")
    ..write(logRecord.message.toString())..write(": ")
    ..write(logRecord.exception);
    print(sb.toString());
  });
}

main() {
  configureLogger();
  
  int port = Platform.environment['PORT'] != null ?
      int.parse(Platform.environment['PORT'], onError: (_) => 8080) :
      8080;

  String dbUrl;
  if (Platform.environment['DATABASE_URL'] != null) {
    dbUrl = Platform.environment['DATABASE_URL'];
  } else {
    String user = Platform.environment['USER'];
    dbUrl = 'postgres://$user:@localhost:5432/$user';
  }
  
  log.info("DB URL is $dbUrl");
  
  String root = path.join(path.dirname(path.current), 'web');
  
  runZoned(() {
    
    db.init(dbUrl)
    .then((_) => HttpServer.bind('0.0.0.0', 8765))
    .then((HttpServer server) {
      
      VirtualDirectory staticFiles = new VirtualDirectory(root)
        ..followLinks = true;
      
      
      
      new Router(server)
        ..serve('/matches', method: 'GET')
          .transform(new HttpBodyHandler()).listen(listMatches)
        ..serve('/matches', method: 'POST')
          .transform(new HttpBodyHandler()).listen(createMatch)

        // BUG: https://code.google.com/p/dart/issues/detail?id=14196
        ..defaultStream.listen(staticFiles.serveRequest);
      
      log.info('Server running');
    });
    
  },
  onError: (e) => log.severe("Error handling request: $e"));

}

void createMatch(HttpRequestBody body) {
  log.fine('Create match');
  Map data = body.body;
  Match match = new Match.fromJson(data);
  match.store().then((_) {
    body.response.statusCode = 201;
    body.response.close();
  })
  .catchError((e) => _handleError(body, e));
  

}

void listMatches(HttpRequestBody body) {
  log.fine('Listing matches');
  db.Persistable.all(Match).toList().then((List<Match> matches) {
    String json = JSON.encode(matches);
    body.response.headers.contentType = ContentType.parse('application/json');
    body.response.contentLength = json.length;
    body.response.write(json);
    body.response.close();
  })
  .catchError((e) => _handleError(body, e));
}

void _handleError(HttpRequestBody body, e) {
  log.severe('Oh noes! $e', getAttachedStackTrace(e));
  body.response.statusCode = 500;
  body.response.close();
}