library hello_static;

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:json' as json;

import "package:logging/logging.dart";
import "package:fukiya/fukiya.dart";

import 'package:tilebasedwordsearch/shared_io.dart';
import 'package:tilebasedwordsearch/persistable_io.dart' as db;
import "package:google_oauth2_client/google_oauth2_console.dart" as console_auth;
import "package:google_plus_v1_api/plus_v1_api_console.dart";
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import "package:html5lib/dom.dart";
import "package:html5lib/dom_parsing.dart";

// Needs to be the same one used on the client side.
final String CLIENT_ID = "250963735330.apps.googleusercontent.com";
final String CLIENT_SECRET = "u-Bk_3yhNjC6YCg7-yG6XeoL";

final String TOKENINFO_URL = "https://www.googleapis.com/oauth2/v1/tokeninfo";
final String TOKEN_ENDPOINT = 'https://accounts.google.com/o/oauth2/token';
final String TOKEN_REVOKE_ENDPOINT = 'https://accounts.google.com/o/oauth2/revoke';

final Random random = new Random();
final Logger _log = new Logger("server");
final String INDEX_HTML = "./web/out/index.html";

Fukiya fukiya;
Boards boards;

void main() {
  _setupLogger();

  _log.fine("Starting Server");

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
    _log.fine("boardgen = ${path}");
    return new File.fromPath(path).readAsString();
  }, onError: (e) {
    _log.fine('Error connecting to db: $e');
    return new Future.error(e);
  })
  .then((String lines) {
    boards = new Boards(lines);
  })
  .then((_) {
    _log.fine('DB connected, now starting up web server');

    fukiya = new Fukiya()
    ..get('/', getIndexHandler)
    // This will just catch the static index.html, we dont want that.
    // Bug reported.
    // ..get('/index.html', getIndexHandler)
    ..get('/index', getIndexHandler)
    ..get('/session', getSessionHandler)
    ..post('/connect', postConnectDataHandler)
    ..post('/disconnect', postDisconnectHandler)
    ..get('/multiplayer_games/new', getNewMultiplayerGame)
    ..post('/multiplayer_games', createMultiplayerGame)
    ..staticFiles('./web/out')
    ..use(new FukiyaJsonParser())
    ..use(new FukiyaFormParser())
    ..listen('0.0.0.0', port);
  })
  .catchError((e) => _log.fine("error starting up: $e"));
}

/**
 * Return a state token to the client and store in the http session.
 */
void getSessionHandler(FukiyaContext context) {
  context.request.session["state_token"] = _createStateToken();
  Map data = { "state_token": context.request.session["state_token"],
               "message" : "Session Established."
             };
  context.send(json.stringify(data));
}

/**
 * Revoke current user's token and reset their session.
 */
void postDisconnectHandler(FukiyaContext context) {
  _log.fine("postDisconnectHandler");
  _log.fine("context.request.session = ${context.request.session}");

  String tokenData = context.request.session.containsKey("access_token") ?
      context.request.session["access_token"] : null;

  if (tokenData == null) {
    context.response.statusCode = 401;
    context.send("Current user not connected.");
    return;
  }

  final String revokeTokenUrl = "${TOKEN_REVOKE_ENDPOINT}?token=${tokenData}";
  context.request.session.remove("access_token");

  new http.Client()
  ..get(revokeTokenUrl).then((http.Response response) {
    _log.fine("GET ${revokeTokenUrl}");
    _log.fine("Response = ${response.body}");
    context.request.session["state_token"] = _createStateToken();
    Map data = {
                "state_token": context.request.session["state_token"],
                "message" : "Successfully disconnected."
                };
    _sendJson(context, data);
  });
}

/**
 * Sends the client a index file with state token and starts the client
 * side authentication process.
 */
void getIndexHandler(FukiyaContext context) {
  _log.fine("getIndexHandler");
  
  // Readin the index file.
  // TODO: cache the INDEX_HTML file into memory
  var file = new File(INDEX_HTML);
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsString().then((String indexDocument) {
        Document doc = new Document.html(indexDocument);
        context.response.write(doc.outerHtml);
        context.response.done.catchError((e) => _log.fine("File Response error: ${e}"));
        context.response.close();
      }, onError: (error) => _log.fine("error = $error"));
    } else {
      _log.fine("getIndexHandler exists = $exists");
      context.response.statusCode = 404;
      context.response.close();
    }
  })
  .catchError((e) => _log.fine("error: $e"));
}

/**
 * Returns a list of friends that have also installed the game.
 */
void getNewMultiplayerGame(FukiyaContext context) {
  String accessToken = context.request.session["access_token"];
  
  runZonedExperimental(() {
    getAllFriends(accessToken).transform(new StreamTransformer<List<Person>, List<Player>>(
        handleData: (List<Person> people, EventSink<List<Player>> sink) {
          int numFriends = people == null ? 0 : people.length;
          _log.fine('Found $numFriends friends of current player');
          
          if (people == null) {
            sink.add([]);
          } else {
            List gplusIds = people.map((Person p) => p.id).toList(growable: false);
            db.Persistable.findBy(Player, {'gplus_id': gplusIds}).toList().then((List<Player> players) {
              int numPlayers = players == null ? 0 : players.length;
              _log.fine('Found ${numPlayers} friends of current player that are players');
              sink.add(players);
            })
            .catchError((e) => sink.addError(e));
          }
        }))
      .toList()
      .then((List<List<Player>> players) {
        List<Player> flat = players.expand((i) => i).toList();
        _sendJson(context, flat);
      })
      .catchError((e) {
        _log.warning('Problem finding friends: $e');
        context.response.statusCode = 500;
      })
      .whenComplete(() {
        context.response.close();
      });
  },
  onError: print);

}

Future _sendJson(FukiyaContext context, object) {
  context.response.headers.contentType
    = new ContentType("application", "json", charset: "utf-8");
  context.response.write(json.stringify(object));
  return context.response.close();
}

void createMultiplayerGame(FukiyaContext context) {
  Map params = context.parsedBody;
  _log.fine('createMultiplayerGame: $params');
  
  if (params['opponentGplusId'] == null) {
    context.response.statusCode = 500;
    context.response.write('Missing opponentGplusId');
    context.response.close();
    return;
  }
  
  String opponentGplusId = params['opponentGplusId'];
  db.Persistable.findOneBy(Player, {'gplus_id': opponentGplusId}).then((Player player) {
    if (player == null) {
      String msg = 'No player with id $opponentGplusId found opponentGplusId';
      _log.warning(msg);
      context.response.statusCode = 404;
      context.response.write(msg);
      context.response.close();
      return;
    }
    
    String currentUserGplusId = context.request.session['userGplusId'];
    
    BoardConfig boardConfig = new BoardConfig(boards);
    TwoPlayerMatch match = new TwoPlayerMatch(boardConfig,
        currentUserGplusId, opponentGplusId);
    
    return match.store().then((_) => match);
  })
  .then((TwoPlayerMatch match) {
    _sendJson(context, match);
  })
  .catchError((e) {
    _log.warning('Error from creating multiplayer game: $e ${getAttachedStackTrace(e)}');
    
    if (e is json.JsonUnsupportedObjectError) {
      print(e.cause);
      print(e.unsupportedObject);
    }
    context.response.statusCode = 500;
    context.response.close();
  });
}

/**
 * Upgrade given auth code to token, and store it in the session.
 * POST body of request should be the authorization code.
 * Example URI: /connect?state=...&gplus_id=...
 */
void postConnectDataHandler(FukiyaContext context) {
  _log.fine("postConnectDataHandler");
  
  _confirmOauthSignin(context).then((String userGplusId) {
    String accessToken = context.request.session['access_token'];
    return getCurrentPerson(accessToken);
  }).then((Person currentPerson) {
    db.Persistable.findOneBy(Player, {'gplus_id': currentPerson.id}).then((Player player) {
      if (player == null) {
        _log.info('No player found for gplusId userGplusId');
        // TODO save the player's name
        var p = new Player()
          ..name = currentPerson.displayName
          ..gplus_id = currentPerson.id;
        p.store().then((_) {
          context.request.session['player_id'] = p.id;
          context.send("POST OK");
        })
        .catchError((e) {
          _log.severe('Did not store new person userGplusId into db: $e');
          context.response.statusCode = 500;
          context.response.close();
        });
      } else {
        _log.info('Found the player ${player}');
      }
    });
  })
  .catchError((e) {
    _log.warning(e);
    context.response.statusCode = 500;
    context.response.close();
  });
}

Future<String> _confirmOauthSignin(FukiyaContext context) {

  String tokenData = context.request.session["access_token"]; // TODO: handle missing token
  String stateToken = context.request.session["state_token"];
  String queryStateToken = context.request.uri.queryParameters["state_token"];
  
  // Check if the token already exists for this session.
  if (tokenData != null) {
    return new Future.value(context.request.uri.queryParameters["gplus_id"]);
  }
  
  // Check if any of the needed token values are null or mismatched.
  if (stateToken == null || queryStateToken == null || stateToken != queryStateToken) {
    return new Future.error('Invalid state parameter: $stateToken $queryStateToken');
  }
  
  Completer completer = new Completer();
  
  // Normally the state would be a one-time use token, however in our
  // simple case, we want a user to be able to connect and disconnect
  // without reloading the page.  Thus, for demonstration, we don't
  // implement this best practice.
  context.request.session.remove("state_token");
  
  String gPlusId = context.request.uri.queryParameters["gplus_id"];
  StringBuffer sb = new StringBuffer();
  // Read data from request.
  context.request
  .transform(new StringDecoder())
  .listen((data) => sb.write(data), onDone: () {
    _log.fine("context.request.listen.onDone = ${sb.toString()}");
    Map requestData = json.parse(sb.toString());
  
    Map fields = {
              "grant_type": "authorization_code",
              "code": requestData["code"],
              // http://www.riskcompletefailure.com/2013/03/postmessage-oauth-20.html
              "redirect_uri": "postmessage",
              "client_id": CLIENT_ID,
              "client_secret": CLIENT_SECRET
    };
  
    _log.fine("fields = $fields");
    http.Client _httpClient = new http.Client();
    _httpClient.post(TOKEN_ENDPOINT, fields: fields).then((http.Response response) {
      // At this point we have the token and refresh token.
      var credentials = json.parse(response.body);
      _log.fine("credentials = ${response.body}");
      _httpClient.close();
  
      var verifyTokenUrl = '${TOKENINFO_URL}?access_token=${credentials["access_token"]}';
      new http.Client()
      ..get(verifyTokenUrl).then((http.Response response)  {
        _log.fine("response = ${response.body}");
  
        var verifyResponse = json.parse(response.body);
        String userGplusId = verifyResponse["user_id"];
        String accessToken = credentials["access_token"];
        if (userGplusId != null && userGplusId == gPlusId && accessToken != null) {
          context.request.session["access_token"] = accessToken;
          context.request.session['userGplusId'] = userGplusId;
          
          _log.info('Set the access token to $accessToken');
          
          completer.complete(userGplusId);
        } else {
          context.response.statusCode = 401;
          context.send("POST FAILED ${userGplusId} != ${gPlusId}");
          completer.completeError("POST FAILED ${userGplusId} != ${gPlusId}");
        }
      });
    });
  });
  
  return completer.future;
}

/**
 * Logger configuration.
 */
void _setupLogger() {
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

Stream<List<Person>> getAllFriends(String accessToken) {
  
  StreamController stream = new StreamController();
  
  Future consumePeople([String nextToken]) {
    return getPageOfFriends(accessToken, nextPageToken: nextToken)
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

Future<Person> getCurrentPerson(String accessToken) {
  Plus plusclient = makePlusClient(accessToken);
  return plusclient.people.get('me');
}

Future<PeopleFeed> getPageOfFriends(String accessToken,
    {String orderBy: 'best', int maxResults: 100, String nextPageToken}) {
  Plus plusclient = makePlusClient(accessToken);
  
  return plusclient.people.list('me', 'visible', orderBy: orderBy,
      maxResults: maxResults, pageToken: nextPageToken);
}

Plus makePlusClient(String accessToken) {
  SimpleOAuth2 simpleOAuth2 = new SimpleOAuth2()
      ..credentials = new console_auth.Credentials(accessToken);
  Plus plusclient = new Plus(simpleOAuth2);
  plusclient.makeAuthRequests = true;
  return plusclient;
}

/**
 * Simple OAuth2 class for making requests and storing credentials in memory.
 */
class SimpleOAuth2 implements console_auth.OAuth2Console {
  final Logger logger = new Logger("SimpleOAuth2");

  /// The URL from which the pub client will request an access token once it's
  /// been authorized by the user.
  Uri _tokenEndpoint = Uri.parse('https://accounts.google.com/o/oauth2/token');
  Uri get tokenEndpoint => _tokenEndpoint;

  console_auth.Credentials _credentials;
  console_auth.Credentials get credentials => _credentials;
  void set credentials(value) {
    _credentials = value;
  }
  console_auth.SystemCache _systemCache;
  console_auth.SystemCache get systemCache => _systemCache;

  void clearCredentials(console_auth.SystemCache cache) {
    logger.fine("clearCredentials(console_auth.SystemCache $cache)");
  }

  Future withClient(Future fn(console_auth.Client client)) {
    logger.fine("withClient(Future ${fn}(console_auth.Client client))");
    console_auth.Client _httpClient = new console_auth.Client(CLIENT_ID, CLIENT_SECRET, _credentials);
    return fn(_httpClient);
  }

  void close() {
    logger.fine("close()");
  }
}
