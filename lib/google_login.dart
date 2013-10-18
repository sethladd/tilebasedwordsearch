library google_login;

import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:js/js.dart" as js;
import 'dart:html';
import 'package:logging/logging.dart';

typedef OnSignInCallback(SimpleOAuth2 authenticationContext, [Map authResult]);
typedef OnSignOutCallback();

final Logger log = new Logger('without-polymer');

OnSignInCallback signInCallback;
OnSignOutCallback signOutCallback;
SimpleOAuth2 authenticationContext;

_onSignInCallback() {
  print('signed in!');
}

init() {
    
  //authenticationContext = new SimpleOAuth2(null);
  
  /**
   * Calls the method that handles the authentication flow.
   *
   * @param {Object} authResult An Object which contains the access token and
   *   other authentication information.
   */
  js.scoped(() {

    js.context["onSignInCallback"] =  new js.Callback.many((js.Proxy authResult) {
      _onSignInCallback();
    });
    
    ScriptElement script = new ScriptElement()
        ..src = "https://plus.google.com/js/client:plusone.js?onLoadCallback=__gsignin_loaded"
        ..async = true;
    
    // don't need this, there's no shadowdom so the button is found
    //js.context.gapi.signin.render($['signin'], js.map($['signin'].dataset));
  });
}
