import 'package:polymer/polymer.dart';
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:google_plus_v1_api/plus_v1_api_browser.dart";
import "package:js/js.dart" as js;
import 'dart:html';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'dart:convert' show JSON;
import 'dart:async';

final Logger log = new Logger('google-signin-element');

@CustomTag('google-signin')
class GoogleSignin extends PolymerElement {
  @observable bool isConnected = false;
  @published String clientId;
  @published String signInMsg;
  @published String serverUrl;
  @observable String oauthStateToken;
  @observable String gplusId;
  
  SimpleOAuth2 authenticationContext;
  @observable Plus plusClient;

  _onSignInCallback(Map authResult) {
    log.fine('In signin callback');
    if (authResult["access_token"] != null) {
      log.fine('looks like signin worked!');
      
      authenticationContext = new SimpleOAuth2(null);
      
      // Enable Authenticated requested with the granted token in the client libary
      authenticationContext.token = authResult["access_token"];
      authenticationContext.tokenType = authResult["token_type"];
      
      plusClient = new Plus(authenticationContext);
      plusClient.makeAuthRequests = true;
      
      _requestSessionToken()
      .then((_) => plusClient.people.get('me'))
      // TODO when https://code.google.com/p/dart/issues/detail?id=14196 is
      // fixed, add these back
      .then((Person person) => gplusId = person.id)
      .then((_) => _connectWithServer(authResult))
      .then((_) {
        isConnected = true;
        dispatchEvent(new CustomEvent('signincomplete'));
      });

    } else if (authResult["error"] != null) {
      log.severe("There was an error authenticating: ${authResult["error"]}");
      dispatchEvent(new CustomEvent('signinerror', detail: authResult["error"]));
    }
  }
  
  Future _connectWithServer(Map authResult) {
    final String stateToken = oauthStateToken;
    final String url = "${serverUrl}/connect?state_token=${stateToken}&gplus_id=${gplusId}";
    log.fine("Connecting with oauth server at $url");
    
    return HttpRequest.request(url, method: "POST",
                                    withCredentials: true,
                                    requestHeaders: {'Content-Type': 'application/json'},
                                    sendData: JSON.encode(authResult))
        .then((HttpRequest request) {
          log.fine("OAuth2 connected with status ${request.responseText}");
          if (request.status == 401) {
            log.fine("Oauth2 server connect 401: request.responseText = ${request.responseText}");
            return;
          }

        }).catchError((error) {
          log.fine("Oauth2 Server Connect Error: $error");
        });
  }
  
  /**
   * Request the anti-request forgery state token. 
   */
  Future _requestSessionToken() {
    log.fine('Getting state token');
    return HttpRequest.getString("${serverUrl}/session", withCredentials: true)
      .then((data) {
        var stateTokenData = JSON.decode(data);
        oauthStateToken = stateTokenData['state_token'];
        log.fine('State token retrieval successful');
      })
      .catchError((error) {
        log.severe("Requesting Session Token Failed: $error");
      });
  }
  
  // BUG, can't use shadow dom for some reason.
  // See https://code.google.com/p/dart/issues/detail?id=14210
  // See also https://code.google.com/p/dart/issues/detail?id=14230
  @override
  ShadowRoot shadowFromTemplate(Element template) {
    TemplateElement tmpl = template as TemplateElement;
    host.append(tmpl.content.clone(true));
  }

  void created() {
    super.created();
    
    /**
     * Calls the method that handles the authentication flow.
     *
     * @param {Object} authResult An Object which contains the access token and
     *   other authentication information.
     */
    js.scoped(() {
      js.context["onSignInCallback"] =  new js.Callback.many((js.Proxy authResult) {
        Map dartAuthResult =
            JSON.decode(js.context["JSON"]["stringify"](authResult));
        _onSignInCallback(dartAuthResult);
      });
      
      ButtonElement button = host.query('#signin');
      button.dataset['clientId'] = clientId;
      button.text = signInMsg;
      
      //js.context.gapi.signin.render(button, js.map(button.dataset));
    });
    
    ScriptElement script = new ScriptElement()
    ..type = 'text/javascript'
    ..src = 'https://plus.google.com/js/client:plusone.js'
    ..async = true;
    document.body.append(script);
  }
}