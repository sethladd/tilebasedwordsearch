part of server;

final String CLIENT_ID = "250963735330.apps.googleusercontent.com";
final String CLIENT_SECRET = "u-Bk_3yhNjC6YCg7-yG6XeoL";

final String TOKENINFO_URL = "https://www.googleapis.com/oauth2/v1/tokeninfo";
final String TOKEN_ENDPOINT = 'https://accounts.google.com/o/oauth2/token';
final String TOKEN_REVOKE_ENDPOINT = 'https://accounts.google.com/o/oauth2/revoke';

/**
 * Upgrade given auth code to token, and store it in the session.
 * POST body of request should be the authorization code.
 * Example URI: /connect?state=...&gplus_id=...
 */
void oauthConnect(HttpRequest request) {
  log.fine("Inside oauthConnect");
  
  _confirmOauthSignin(request)
  .catchError((e) {
    log.warning(e);
    request.response.statusCode = 500;
    request.response.close();
  });
}

/**
 * Expects an "authResult" object encoded as JSON in the request body.
 */
Future<String> _confirmOauthSignin(HttpRequest request) {
  
  log.fine('Oauth2 signin with ${new Map.from(request.uri.queryParameters)}');
  log.fine('Session is ${new Map.from(request.session)}');
  
  final String tokenData = request.session["access_token"]; // TODO: handle missing token
  final String stateToken = request.session["state_token"];
  final String queryStateToken = request.uri.queryParameters["state_token"];
  final String gPlusId = request.uri.queryParameters["gplus_id"];
  
  // Check if the token already exists for this session.
  if (tokenData != null) {
    return new Future.value(request.uri.queryParameters["gplus_id"]);
  }
  
  // Check if any of the needed token values are null or mismatched.
  if (stateToken == null || queryStateToken == null || stateToken != queryStateToken) {
    return new Future.error('Invalid state parameter: $stateToken $queryStateToken');
  }
  
  // TODO: remove need for completer by chaining futures below
  Completer completer = new Completer();
  
  // Normally the state would be a one-time use token, however in our
  // simple case, we want a user to be able to connect and disconnect
  // without reloading the page.  Thus, for demonstration, we don't
  // implement this best practice.
  request.session.remove("state_token");

  HttpBodyHandler.processRequest(request)
  .then((HttpRequestBody body) {
    Map requestData = body.body as Map;
  
    Map fields = {
      "grant_type": "authorization_code",
      "code": requestData["code"],
      // http://www.riskcompletefailure.com/2013/03/postmessage-oauth-20.html
      "redirect_uri": "postmessage",
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET
    };
  
    log.fine("fields = $fields");
    http.Client _httpClient = new http.Client();
    _httpClient.post(TOKEN_ENDPOINT, fields: fields).then((http.Response response) {
      // At this point we have the token and refresh token.
      Map credentials = JSON.decode(response.body);
      log.fine("credentials = ${response.body}");
      _httpClient.close();
  
      var verifyTokenUrl = '${TOKENINFO_URL}?access_token=${credentials["access_token"]}';
      new http.Client()
      ..get(verifyTokenUrl).then((http.Response response)  {
        log.fine("response = ${response.body}");
  
        var verifyResponse = JSON.decode(response.body);
        String userGplusId = verifyResponse["user_id"];
        String accessToken = credentials["access_token"];
        if (userGplusId != null && userGplusId == gPlusId && accessToken != null) {
          request.session["access_token"] = accessToken;
          request.session['userGplusId'] = userGplusId;
          request.session['userName'] = request.uri.queryParameters['name'];
          
          log.info('The user is logged in. Set the access token to $accessToken');
          
          completer.complete(userGplusId);
        } else {
          request.response.statusCode = 401;
          request.response.write("POST FAILED ${userGplusId} != ${gPlusId}");
          completer.completeError("POST FAILED ${userGplusId} != ${gPlusId}");
        }
      });
    });
  });
  
  return completer.future;
}

/**
 * Return a state token to the client and store in the http session.
 */
void oauthSession(HttpRequest request) {
  log.fine('Inside oauthSession');
  
  String stateToken = _createStateToken();
  request.session["state_token"] = stateToken;
  Map data = { "state_token": request.session["state_token"],
               "message" : "Session Established."
             };
  request.response.headers.add('Content-Type', 'application/json');
  request.response.write(JSON.encode(data));
  request.response.close();
  
  log.fine('Put $stateToken into session: ${request.session['state_token']}');
}

/**
 * Creating state token based on random number.
 */
String _createStateToken() {
  Random random = new Random();
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
class SimpleOAuth2 implements oauth2.OAuth2Console {
  final Logger logger = new Logger("SimpleOAuth2");

  /// The URL from which the pub client will request an access token once it's
  /// been authorized by the user.
  Uri _tokenEndpoint = Uri.parse('https://accounts.google.com/o/oauth2/token');
  Uri get tokenEndpoint => _tokenEndpoint;

  oauth2.Credentials _credentials;
  oauth2.Credentials get credentials => _credentials;
  void set credentials(value) {
    _credentials = value;
  }
  oauth2.SystemCache _systemCache;
  oauth2.SystemCache get systemCache => _systemCache;

  void clearCredentials(oauth2.SystemCache cache) {
    logger.fine("clearCredentials(console_auth.SystemCache $cache)");
  }

  Future withClient(Future fn(oauth2.Client client)) {
    logger.fine("withClient(Future ${fn}(console_auth.Client client))");
    oauth2.Client _httpClient = new oauth2.Client(CLIENT_ID, CLIENT_SECRET, _credentials);
    return fn(_httpClient);
  }

  void close() {
    logger.fine("close()");
  }
}
