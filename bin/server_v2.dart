library server;

import 'package:http_server/http_server.dart';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:route/server.dart';
import 'package:path/path.dart' as path;
import 'package:wordherd/persistable_io.dart' as db;
import 'package:wordherd/shared_io.dart';
import 'dart:convert' show JSON;
import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:serialization/serialization.dart';
import 'package:google_oauth2_client/google_oauth2_console.dart' as oauth2;
import 'package:google_plus_v1_api/plus_v1_api_console.dart';

part 'oauth_handler.dart';

final Logger log = new Logger('Server');
final Serialization serializer = new Serialization();

configureLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord logRecord) {
    StringBuffer sb = new StringBuffer();
    sb
    ..write(logRecord.time.toString())..write(":")
    ..write(logRecord.loggerName)..write(":")
    ..write(logRecord.level.name)..write(":")
    ..write(logRecord.sequenceNumber)..write(": ")
    ..write(logRecord.message.toString());
    if (logRecord.exception != null) {
      sb
      ..write(": ")
      ..write(logRecord.exception);
    }
    print(sb.toString());
  });
}

final UrlPattern getMatchUrl = new UrlPattern('/matches/(\d+)');

Boards boards;

main() {
  configureLogger();

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
    .then((_) => loadData())
    .then((_) => HttpServer.bind('0.0.0.0', 8765))
    .then((HttpServer server) {
      
      VirtualDirectory staticFiles = new VirtualDirectory(root)
        ..followLinks = true;
      
      new Router(server)
        ..filter(new RegExp(r'^.*$'), addCorsHeaders)
        ..serve('/session', method: 'GET').listen(oauthSession)
        ..serve('/connect', method: 'POST').listen(oauthConnect) // TODO use HttpBodyHandler when dartbug.com/14259 is fixed
        ..serve('/register', method: 'POST')
          .transform(new HttpBodyHandler()).listen(registerPlayer)
        ..serve('/friendsToPlay', method: 'GET').listen(friendsToPlay)
        ..serve('/matches', method: 'GET')
          .transform(new HttpBodyHandler()).listen(listMatches)
        ..serve('/matches', method: 'POST')
          .transform(new HttpBodyHandler()).listen(createMatch)
        ..serve(getMatchUrl).listen(getMatch)

        // BUG: https://code.google.com/p/dart/issues/detail?id=14196
        ..defaultStream.listen(staticFiles.serveRequest);
      
      log.info('Server running');
    });
    
  },
  onError: (e) => log.severe("Error handling request: $e"));

}

Future loadData() {
  File boardData = new File('dense1000FINAL.txt');
  return boardData.readAsString().then((String data) => boards = new Boards(data));
}

Future<bool> addCorsHeaders(HttpRequest req) {
  log.fine('Adding CORS headers for ${req.method} ${req.uri}');
  req.response.headers.add('Access-Control-Allow-Origin', 'http://127.0.0.1:3030');
  req.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
  req.response.headers.add('Access-Control-Expose-Headers', 'Location');
  req.response.headers.add('Access-Control-Allow-Credentials', 'true');
  if (req.method == 'OPTIONS') {
    req.response.statusCode = 200;
    req.response.close(); // TODO: wait for this?
    return new Future.sync(() => false);
  } else {
    return new Future.sync(() => true);
  }
}

void getMatch(HttpRequest request) {
  // TODO wouldn't it be nice if this was passed in for me so I didn't
  // have to parse it again?
  var matchId = getMatchUrl.parse(request.uri.path)[0];
  db.Persistable.findOneBy(Match, {'id': matchId}).then((Match match) {
    if (match == null) {
      request.response.statusCode = 404;
      request.response.close();
    } else {
      // TODO verify the match is for the player
      _sendJson(request.response, match);
    }
  })
  .catchError((e) => _handleError(e, request.response));
}

void registerPlayer(HttpRequestBody body) {
  log.fine('Register player');
  Map data = body.body;
  String gplusId = data['gplus_id'];

  // TODO check the logged in session user matches this user
  
  db.Persistable.findOneBy(Player, {'gplus_id':gplusId}).then((Player p) {
    if (p == null) {
      Player player = new Player()
      ..gplus_id = data['gplus_id']
      ..name = data['name'];
      return player.store().then((_) => body.response.statusCode = 201);
    } else {
      body.response.statusCode = 200;
      return true;
    }
  })
  .then((_) {
    log.fine('All done registering');
    body.response.close();
  })
  .catchError((e) => _handleError(body.response, e));
}

/**
 * Returns a list of friends that have also installed the game.
 */
void friendsToPlay(HttpRequest request) {
  log.fine('Inside getFriendPlayers');
  
  String accessToken = request.session["access_token"];
  
  _getAllFriends(accessToken).transform(new StreamTransformer<List<Person>, List<Player>>(
      handleData: (List<Person> people, EventSink<List<Player>> sink) {
        int numFriends = people == null ? 0 : people.length;
        log.fine('Found $numFriends friends of current player');
        
        if (people == null) {
          sink.add([]);
        } else {
          List gplusIds = people.map((Person p) => p.id).toList(growable: false);
          db.Persistable.findBy(Player, {'gplus_id': gplusIds}).toList().then((List<Player> players) {
            int numPlayers = players == null ? 0 : players.length;
            log.fine('Found ${numPlayers} friends of current player that are players');
            sink.add(players);
          })
          .catchError((e) => sink.addError(e));
        }
      }))
    .toList()
    .then((List<List<Player>> players) {
      List<Player> flat = players.expand((i) => i).toList();
      _sendJson(request.response, flat);
    })
    .catchError((e) {
      log.warning('Problem finding friends: $e');
      request.response.statusCode = 500;
    })
    .whenComplete(() {
      request.response.close();
    });

}

Stream<List<Person>> _getAllFriends(String accessToken) {
  Plus plusclient = makePlusClient(accessToken);
  
  StreamController stream = new StreamController();
  
  Future consumePeople([String nextToken]) {
    return _getPageOfFriends(plusclient, nextPageToken: nextToken)
      .then((PeopleFeed feed) {
        stream.add(feed.items);
        if (feed.nextPageToken != null) {
          return consumePeople(feed.nextPageToken);
        }
      });
  }
  
  consumePeople()
      .catchError((e) {
        stream.addError(e);
      })
      .whenComplete(() {
        stream.close();
      });
  
  return stream.stream;
}

Future<PeopleFeed> _getPageOfFriends(Plus plusclient,
    {String orderBy: 'best', int maxResults: 100, String nextPageToken}) {
  return plusclient.people.list('me', 'visible', orderBy: orderBy,
      maxResults: maxResults, pageToken: nextPageToken);
}

void createMatch(HttpRequestBody body) {
  log.fine('Create match');
  Map data = body.body;
  
  Match match = new Match()
      ..p1_id = data['p1_id']
      ..p2_id = data['p2_id']
      ..board = boards.generateBoard();
  match.store().then((_) {
    body.response.statusCode = 201;
    body.response.headers.add('Location', '/matches/${match.id}'); // TODO make into absolute URI
    body.response.close();
  })
  .catchError((e) => _handleError(body.response, e));
}

void listMatches(HttpRequestBody body) {
  log.fine('Listing matches');
  db.Persistable.all(Match).toList().then((List<Match> matches) {
    _sendJson(body.response, matches);
  })
  .catchError((e) => _handleError(body.response, e));
}

void _handleError(HttpResponse response, e) {
  log.severe('Oh noes! $e', getAttachedStackTrace(e));
  response.statusCode = 500;
  response.close();
}

Future<Person> getCurrentPerson(String accessToken) {
  Plus plusclient = makePlusClient(accessToken);
  return plusclient.people.get('me');
}

Plus makePlusClient(String accessToken) {
  SimpleOAuth2 simpleOAuth2 = new SimpleOAuth2()
      ..credentials = new oauth2.Credentials(accessToken);
  Plus plusclient = new Plus(simpleOAuth2);
  plusclient.makeAuthRequests = true;
  return plusclient;
}

_sendJson(HttpResponse response, var payload) {
  String json = JSON.encode(serializer.write(payload));
  response.headers.contentType = ContentType.parse('application/json');
  response.contentLength = json.length;
  response.write(json);
  response.close();
}