import 'dart:html';
import 'dart:json' as JSON;
import "package:js/js.dart" as js;
import 'package:web_ui/web_ui.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart' as app;
import "package:google_oauth2_client/google_oauth2_browser.dart";

typedef OnSignInCallback(SimpleOAuth2 authenticationContext, [Map authResult]);
typedef OnSignOutCallback();

void enableSignInUI(bool isAnonymous) {
  Element el;
  
  el = query(".welcome");
  if (el != null) {
    el.hidden = isAnonymous;
  }
  
  el = query("#disconnect");
  if (el != null) {
    el.hidden = isAnonymous;
  }
  
  el = query("#google-connect");
  if (el != null) {
    el.hidden = !isAnonymous;
  }
}

class LoginPanel extends WebComponent {
  OnSignInCallback signInCallback;
  OnSignOutCallback signOutCallback;
  SimpleOAuth2 authenticationContext;

  _onSignInCallback(Map authResult) {
    print("authRequest = ${authResult}");

    if (authResult["access_token"] != null) {
      enableSignInUI(false);

      // Enable Authenticated requested with the granted token in the client libary
      authenticationContext.token = authResult["access_token"];
      authenticationContext.tokenType = authResult["token_type"];

      // Notify
      if (signInCallback != null) {
        signInCallback(authenticationContext, authResult);
      }
    } else if (authResult["error"] != null) {
      print("There was an error: ${authResult["error"]}");
      enableSignInUI(true);
    }
  }
  
  /**
   * Calls the OAuth2 endpoint to disconnect the app for the user.
   */
  void disconnect(event) {
    js.scoped(() {
      // JSONP workaround because the accounts.google.com endpoint doesn't allow CORS
      js.context["myJsonpCallback"] = new js.Callback.once(([jsonData]) {
        // disable authenticated requests in the client library
        authenticationContext.token = null;

        if (signOutCallback != null) {
          signOutCallback();
        }
      });

      ScriptElement script = new Element.tag("script");
      script.src = "https://accounts.google.com/o/oauth2/revoke?token=${authenticationContext.token}&callback=myJsonpCallback";
      document.body.children.add(script);
      enableSignInUI(true);
    });
  }

  void created() {
    //authenticationContext = new SimpleOAuth2(null);

    /**
     * Calls the method that handles the authentication flow.
     *
     * @param {Object} authResult An Object which contains the access token and
     *   other authentication information.
     */
    js.scoped(() {
      var reviverOAuth = new js.Callback.many((key, value) {
        if (key == "g-oauth-window") {
          return "";
        }

        return value;
      });

      js.context["onSignInCallback"] =  new js.Callback.many((js.Proxy authResult) {
        Map dartAuthResult =
            JSON.parse(js.context["JSON"]["stringify"](authResult, reviverOAuth));
        _onSignInCallback(dartAuthResult);
      });
    });

    var script = new ScriptElement();
    script.async = true;
    script.type = "text/javascript";
    script.src = "https://plus.google.com/js/client:plusone.js";
    document.body.children.add(script);
  }

}