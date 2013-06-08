library hello_static;

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:json' as JSON;

import "package:logging/logging.dart";
import "package:fukiya/fukiya.dart";
import 'package:tilebasedwordsearch/persistable.dart' as db;
import "package:google_oauth2_client/google_oauth2_console.dart" as console_auth;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import "package:html5lib/dom.dart";
import "package:html5lib/dom_parsing.dart";

// Needs to be the same one used on the client side.
final String CLIENT_ID = "";
final String CLIENT_SECRET = "";

final String TOKENINFO_URL = "https://www.googleapis.com/oauth2/v1/tokeninfo";
final String TOKEN_ENDPOINT = 'https://accounts.google.com/o/oauth2/token';
final String TOKEN_REVOKE_ENDPOINT = 'https://accounts.google.com/o/oauth2/revoke';

final Random random = new Random();
final Logger serverLogger = new Logger("server");
Fukiya fukiya;
final String INDEX_HTML = "./web/index.html";

void main() {
  _setupLogger();

  serverLogger.fine("Starting Server");

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
//    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
//      serverLogger.fine('HTTP server started');
//      app.get('/games/:id').listen(getGame);
//      app.post('/games').listen(createGame);
//      // /index.html hanlders
//      app.get('/').listen(getIndex);
//      app.get('/index').listen(getIndex);
//      app.get('/index.html').listen(getIndex);
//    });
    fukiya = new Fukiya()
    ..get('/', getIndexHandler)
    ..get('/index.html', getIndexHandler)
    ..get('/index', getIndexHandler)
    ..post('/connect', postConnectDataHandler)
//    ..get('/people', getPeopleHandler)
//    ..post('/disconnect', postDisconnectHandler)
    ..staticFiles('./web')
    ..use(new FukiyaJsonParser())
    ..listen('0.0.0.0', 3333);

  })
  .catchError((e) => serverLogger.fine("error: $e"));
}

/**
 * Sends the client a index file with state token and starts the client
 * side authentication process.
 */
void getIndexHandler(FukiyaContext context) {
  serverLogger.fine("getIndexHandler");
  // Create a state token.
  context.request.session["state_token"] = _createStateToken();

  // Readin the index file and add state token into the meta element.
  // TODO: cache the INDEX_HTML file into memory
  var file = new File(INDEX_HTML);
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsString().then((String indexDocument) {
        Document doc = new Document.html(indexDocument);
        Element metaState = new Element.html('<meta name="state_token" content="${context.request.session["state_token"]}">');
        doc.head.children.add(metaState);
        context.response.write(doc.outerHtml);
        context.response.done.catchError((e) => serverLogger.fine("File Response error: ${e}"));
        context.response.close();
      }, onError: (error) => serverLogger.fine("error = $error"));
    } else {
      context.response.statusCode = 404;
      context.response.close();
    }
  })
  .catchError((e) => serverLogger.fine("error: $e"));
}

/**
 * Upgrade given auth code to token, and store it in the session.
 * POST body of request should be the authorization code.
 * Example URI: /connect?state=...&gplus_id=...
 */
void postConnectDataHandler(FukiyaContext context) {
  serverLogger.fine("postConnectDataHandler");
  String tokenData = context.request.session.containsKey("access_token") ? context.request.session["access_token"] : null; // TODO: handle missing token
  String stateToken = context.request.session.containsKey("state_token") ? context.request.session["state_token"] : null;
  String queryStateToken = context.request.uri.queryParameters.containsKey("state_token") ? context.request.uri.queryParameters["state_token"] : null;

  // Check if the token already exists for this session.
  if (tokenData != null) {
    context.send("Current user is already connected.");
    return;
  }

  // Check if any of the needed token values are null or mismatched.
  if (stateToken == null || queryStateToken == null || stateToken != queryStateToken) {
    context.response.statusCode = 401;
    context.send("Invalid state parameter.");
    return;
  }

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
    serverLogger.fine("context.request.listen.onDone = ${sb.toString()}");
    Map requestData = JSON.parse(sb.toString());

    Map fields = {
              "grant_type": "authorization_code",
              "code": requestData["code"],
              // http://www.riskcompletefailure.com/2013/03/postmessage-oauth-20.html
              "redirect_uri": "postmessage",
              "client_id": CLIENT_ID,
              "client_secret": CLIENT_SECRET
    };

    serverLogger.fine("fields = $fields");
    http.Client _httpClient = new http.Client();
    _httpClient.post(TOKEN_ENDPOINT, fields: fields).then((http.Response response) {
      // At this point we have the token and refresh token.
      var credentials = JSON.parse(response.body);
      serverLogger.fine("credentials = ${response.body}");
      _httpClient.close();

      var verifyTokenUrl = '${TOKENINFO_URL}?access_token=${credentials["access_token"]}';
      new http.Client()
      ..get(verifyTokenUrl).then((http.Response response)  {
        serverLogger.fine("response = ${response.body}");

        var verifyResponse = JSON.parse(response.body);
        String userId = verifyResponse.containsKey("user_id") ? verifyResponse["user_id"] : null;
        String accessToken = credentials.containsKey("access_token") ? credentials["access_token"] : null;
        if (userId != null && userId == gPlusId && accessToken != null) {
          context.request.session["access_token"] = accessToken;
          context.send("POST OK");
        } else {
          context.response.statusCode = 401;
          context.send("POST FAILED ${userId} != ${gPlusId}");
        }
      });
    });
  });
}

//getIndex(Request req) {
//  serverLogger.fine("getIndex");
//
//}

//getGame(Request req) {
//  var id = req.params['id'];
//  db.load(id, 'game').then((Map row) {
//    if (row == null) {
//      req.response.status(HttpStatus.NOT_FOUND);
//      req.response.close();
//    } else {
//      req.response.json(row);
//    }
//  });
//}

//createGame(Request req) {
//  HttpBodyHandler.processRequest(req.input)
//    .then((HttpBody body) {
//
//    })
//    .catchError((e) {
//      req.response
//          ..status(500)
//          ..close();
//    });
//}

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